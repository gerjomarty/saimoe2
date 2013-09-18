## Tournament statistics.
##
## Usage examples:
##
## Statistics.new(Character).get_statistic(:total_votes).fetch_results
## => Returns ranked list of characters with total votes across all tournaments
##
## Statistics.new(Series).get_statistic(:total_votes).for_tournament(Tournament.fy(2012)).fetch_results
## => Returns ranked list of series with total votes in the 2012 tournament only
##
## Statistics.new(VoiceActor).get_statistic(:match_appearances).for_tournament(Tournament.fy(2012)).in_stages.fetch_results
## => Returns Hash mapping tournament stages to ranked lists of voice actors with no. of appearances in those tournament stages
## (Note that #in_stages only really makes sense for one tournament at a time for the moment)
##
## Statistics.new(Character).get_statistic(:total_votes).for_entity(Character.find_by_name('Akari Mizunashi')).fetch_results
## => Returns ranked list of characters with total votes across all tournaments, focusing around the given character
class Statistics
  include ApplicationHelper

  attr_reader :model_class, :render_function, :statistic_type, :sort_in_stages, :winners_only, :tournaments, :cut_off_date, :entity, :should_cut_off_same_rank, :before_context, :after_context

  ALLOWED_MODEL_CLASSES = [Character, Series, VoiceActor]

  def initialize model_class
    unless ALLOWED_MODEL_CLASSES.include?(model_class)
      raise ArgumentError, "model must be one of #{ALLOWED_MODEL_CLASSES.inspect}"
    end

    @model_class = model_class
    @scope = self.class.model_scope model_class
    self
  end

  def == other
    model_class == other.model_class &&
      statistic_type == other.statistic_type &&
      sort_in_stages == other.sort_in_stages &&
      tournaments == other.tournaments &&
      cut_off_date == other.cut_off_date &&
      entity == other.entity &&
      should_cut_off_same_rank == other.should_cut_off_same_rank &&
      before_context == other.before_context &&
      after_context == other.after_context
  end

  def hash
    [model_class, statistic_type, sort_in_stages, tournaments, cut_off_date, entity, should_cut_off_same_rank, before_context, after_context].hash
  end

  def get_statistic stat
    raise 'Only one statistic allowed to be fetched' if @statistic_type

    case stat
    when :total_votes
      get_total_votes
    when :average_votes
      get_average_votes
    when :vote_share
      get_vote_share
    when :match_appearances
      get_match_appearances
    when :match_wins
      get_match_wins
    when :unique_entrants
      get_unique_entrants
    else
      raise ArgumentError, 'Invalid statistic type passed'
    end

    @statistic_type = stat

    self
  end

  def in_stages
    @sort_in_stages = true
    @rank_partition = Match.q_column(:stage)
    
    @scope = @scope.select("#{Match.q_column :stage} AS stage")
                   .group(Match.q_column :stage)
                   .scoped

    self
  end

  def tournaments
    @tournaments || []
  end

  def for_tournaments *tournaments
    @tournaments = Array(tournaments).flatten.compact

    unless tournaments.empty?
      @scope = @scope.where(appearances: {tournament_id: tournaments.collect(&:id)}).scoped
    end

    self
  end

  def for_winners_only
    @winners_only = true

    self
  end

  alias_method :for_tournament, :for_tournaments

  def before_date date
    @cut_off_date = date.try :to_date

    @scope = @scope.where("#{Match.q_column :date} < ?", @cut_off_date).scoped if @cut_off_date

    self
  end

  def for_entity entity, should_cut_off_same_rank=false, before_context=2, after_context=2
    unless ALLOWED_MODEL_CLASSES.any? {|model_class| entity.is_a? model_class }
      raise ArgumentError, "entity must be an instance of one of #{ALLOWED_MODEL_CLASSES.inspect}"
    end

    unless before_context.is_a? Fixnum || before_context == :all
      raise ArgumentError, 'before_context must be >= 0 or :all'
    end
    unless after_context.is_a? Fixnum || after_context == :all
      raise ArgumentError, 'before_context must be >= 0 or :all'
    end

    @entity = entity
    @should_cut_off_same_rank = should_cut_off_same_rank
    @before_context = before_context
    @after_context = after_context

    self
  end

  def render_function
    return lambda {|stat| stat.to_s } unless @render_function
    @render_function
  end

  def fetch_results
    raise 'Must specify statistic to get' unless @statistic_type

    apply_rank
    apply_ordering
    apply_winners
    results = @scope.collect {|r| [r[:rank].to_i,
                                   r[:stage],
                                   r[@stat_name] && @normalization_function.call(r[@stat_name]),
                                   r,
                                   r[:series_id] && r[:series_id].to_i]}
    series = {}.tap {|s_hash| Series.find(results.collect(&:last).uniq.compact).each {|s| s_hash[s.id] = s } }
    results.collect! {|r| r[-1] = series[r[-1]]; r }

    if results.any? {|_, stage, _, _, _| stage }
      results = {}.tap do |stage_hash|
        MatchInfo::STAGES.reverse.each {|s| stage_hash[s] = [] }
        results.each do |r|
          stage_hash[r[1].to_sym] << r.values_at(0, 2..-1)
        end
      end.reject {|_, r| r.empty? }
    else
      results.collect! {|r| r.values_at(0, 2..-1) }
    end

    if @entity && @before_context != :all && @after_context != :all
      if results.is_a? Hash
        results.each do |stage, res|
          results[stage] = filter_to_entity(res)
          results.delete(stage) if results[stage].nil?
        end
      else
        results = filter_to_entity(results)
      end
    end

    results
  end

  private

  def get_total_votes
    @stat_name = :number_of_votes
    @normalization_function = lambda {|votes| votes.to_i }

    @rank_order = "SUM(#{MatchEntry.q_column :number_of_votes}) DESC"

    @scope = @scope.select("SUM(#{MatchEntry.q_column :number_of_votes}) AS #@stat_name")
                   .scoped
  end

  def get_average_votes
    @stat_name = :average_votes
    @normalization_function = lambda {|votes| votes.to_f }
    @render_function = lambda {|votes| format_float(votes) }

    @rank_order = "AVG(#{MatchEntry.q_column :number_of_votes}) DESC"

    @scope = @scope.select("AVG(#{MatchEntry.q_column :number_of_votes}) AS #@stat_name")
                   .scoped
  end

  def get_vote_share
    @stat_name = :vote_share
    @normalization_function = lambda {|votes| votes.to_f }
    @render_function = lambda {|votes| format_percent(votes) }

    @rank_order = "#{MatchEntry.q_column :vote_share} DESC"

    @scope = @scope.select("#{MatchEntry.q_column :vote_share} AS #@stat_name")
                   .group(MatchEntry.q_column :vote_share)
                   .scoped
  end

  def get_match_appearances
    @stat_name = :number_of_match_entries
    @normalization_function = lambda {|mes| mes.to_i }

    @rank_order = "COUNT(DISTINCT #{Match.star}) DESC"

    @scope = @scope.select("COUNT(DISTINCT #{Match.star}) AS #@stat_name")
                   .scoped
  end

  def get_match_wins
    @stat_name = :number_of_match_wins
    @normalization_function = lambda {|wins| wins.to_i }

    @rank_order = "COUNT(DISTINCT #{Match.star}) DESC"

    @scope = @scope.select("COUNT(DISTINCT #{Match.star}) AS #@stat_name")
                   .where(match_entries: {is_winner: true})
                   .scoped
  end

  def get_unique_entrants
    @stat_name = :number_of_characters
    @normalization_function = lambda {|chars| chars.to_i }

    @rank_order = "COUNT(DISTINCT #{Character.star}) DESC"

    @scope = @scope.select("COUNT(DISTINCT #{Character.star}) AS #@stat_name")
                   .scoped
  end

  def character?; model_class == Character; end
  def series?; model_class == Series; end
  def voice_actor?; model_class == VoiceActor; end

  def apply_rank
    return unless @rank_partition || @rank_order
    @scope = @scope.select("rank() OVER (#{"PARTITION BY #@rank_partition " if @rank_partition}ORDER BY #@rank_order)").scoped
  end

  def apply_ordering
    if character?
      @scope = @scope.order(:rank).merge(Series.ordered).ordered.scoped
    else
      @scope = @scope.order(:rank).ordered.scoped
    end
  end

  def apply_winners
    if @winners_only
      @scope = @scope.where(match_entries: {is_winner: true}).scoped
    end
  end

  def filter_to_entity results
    entity_index = results.index {|_, _, e, _| @entity == e }
    return nil if entity_index.nil?

    higher_index = @before_context == :all ? 0 : entity_index - @before_context
    lower_index = @after_context == :all ? results.size - 1 : entity_index + @after_context

    if higher_index < 0
      # Add more context after the entity if there is no before context
      lower_index += (0 - higher_index)
      higher_index = 0
    elsif lower_index > results.size - 1
      # Add more context before the entity if there is no after context
      higher_index -= (lower_index - (results.size - 1))
      lower_index = results.size - 1
    end
    higher_index = [higher_index, 0].max
    lower_index = [lower_index, results.size - 1].min

    return results[higher_index..lower_index] if @should_cut_off_same_rank

    entity_rank = results[entity_index][0]
    higher_rank = results[higher_index][0]
    lower_rank = results[lower_index][0]

    # We want to show every entity with the same bottom rank, and every entity with the same top rank
    higher_index = results.index {|rank, _, _, _| rank == higher_rank }
    lower_index = results.rindex {|rank, _, _, _| rank == lower_rank }

    results[higher_index..lower_index]
  end

  def self.model_scope model_class
    scope = if model_class == Character
              Character.joins([:main_series, :character_roles => {:appearances => [:tournament, {:match_entries => :match}]}])
                       .select("#{Series.q_column :id} AS series_id")
                       .group(Character.q_column :id).group(Series.q_column :id)
                       .scoped
            elsif model_class == Series
              Series.joins(:character_roles => [:character, {:appearances => [:tournament, {:match_entries => :match}]}])
                    .group(Series.q_column :id)
                    .scoped
            elsif model_class == VoiceActor
              VoiceActor.joins(:voice_actor_roles => {:appearance => [:tournament, {:match_entries => :match}, {:character_role => :character}]})
                        .group(VoiceActor.q_column :id)
                        .scoped
            end

    scope.where(match_entries: {is_finished: true}).scoped
  end
end