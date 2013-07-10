class Statistics
  attr_reader :model_class

  ALLOWED_MODEL_CLASSES = [Character, Series, VoiceActor]

  def initialize model_class
    unless ALLOWED_MODEL_CLASSES.include?(model_class)
      raise ArgumentError, "model must be one of #{ALLOWED_MODEL_CLASSES.inspect}"
    end

    @model_class = model_class
    @scope = self.class.model_scope model_class
    self
  end

  def get_total_votes
    raise 'Cannot get total and average votes at once' if @getting_average_votes
    @getting_total_votes = true

    @scope = @scope.select("SUM(#{MatchEntry.q_column :number_of_votes}) as number_of_votes")
                   .select("rank() OVER (ORDER BY SUM(#{MatchEntry.q_column :number_of_votes}) DESC)")
                   .scoped
    self
  end

  def get_average_votes
    raise 'Cannot get total and average votes at once' if @getting_total_votes
    @getting_average_votes = true

    @scope = @scope.select("AVG(#{MatchEntry.q_column :number_of_votes}) as average_votes")
                   .select("rank() OVER (ORDER BY AVG(#{MatchEntry.q_column :number_of_votes}) DESC)")
                   .scoped
    self
  end

  def for_tournaments *tournaments
    tournaments = Array(tournaments).flatten.compact

    unless tournaments.empty?
      @scope = @scope.where(appearances: {tournament_id: tournaments.collect(&:id)}).scoped
    end

    self
  end

  alias_method :for_tournament, :for_tournaments

  def for_entity entity, before_context=5, after_context=5
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
    @before_context = before_context
    @after_context = after_context

    self
  end

  def fetch_results
    raise 'Must specify votes to get' unless @getting_total_votes || @getting_average_votes

    apply_ordering
    results = @scope.collect {|r| [r[:rank].to_i,
                                   r[:number_of_votes] && r[:number_of_votes].to_i,
                                   r[:average_votes] && r[:average_votes].to_f,
                                   r,
                                   r[:series_id] && r[:series_id].to_i]}
    series = {}.tap {|s_hash| Series.find(results.collect(&:last).uniq.compact).each {|s| s_hash[s.id] = s } }
    results.collect! {|r| r[4] = series[r[4]]; r }

    if @entity && @before_context != :all && @after_context != :all
      results = filter_to_entity(results)
    end

    results
  end

  private

  def character?; model_class == Character; end
  def series?; model_class == Series; end
  def voice_actor?; model_class == VoiceActor; end

  def apply_ordering
    if character?
      @scope = @scope.order(:rank).merge(Series.ordered).ordered.scoped
    else
      @scope = @scope.order(:rank).ordered.scoped
    end
  end

  def filter_to_entity results
    entity_index = results.index {|_, _, _, e, _| @entity == e }
    return [] if entity_index.nil?
    higher_index = @before_context == :all ? 0 : [entity_index - @before_context, 0].max
    lower_index = @after_context == :all ? results.size - 1 : [entity_index + @after_context, results.size - 1].min

    entity_rank = results[entity_index][0]
    higher_rank = results[higher_index][0]
    lower_rank = results[lower_index][0]

    # We want to show every entity with the same bottom rank, and every entity with the same top rank
    higher_index = results.index {|rank, _, _, _, _| rank == higher_rank }
    lower_index = results.rindex {|rank, _, _, _, _| rank == lower_rank }

    results[higher_index..lower_index]
  end

  def self.model_scope model_class
    scope = if model_class == Character
              Character.joins(:character_roles => [:series, {:appearances => [:tournament, :match_entries]}])
                       .select("#{Series.q_column :id} AS series_id")
                       .group(Character.q_column :id).group(Series.q_column :id)
                       .scoped
            elsif model_class == Series
              Series.joins(:character_roles => {:appearances => [:tournament, :match_entries]}).scoped
            elsif model_class == VoiceActor
              VoiceActor.joins(:voice_actor_roles => {:appearance => [:tournament, :match_entries]}).scoped
            end

    scope.where(match_entries: {is_finished: true}).scoped
  end
end