class Tournament < ActiveRecord::Base
  include Ordering

  attr_accessible :year, :group_stages, :final_stages
  serialize :group_stages, Array
  serialize :final_stages, Array

  has_many :appearances, inverse_of: :tournament
  has_many :matches, inverse_of: :tournament

  has_many :character_roles, through: :appearances
  has_many :voice_actor_roles, through: :appearances
  has_many :characters, through: :character_roles
  has_many :series, through: :character_roles, uniq: true
  has_many :voice_actors, through: :voice_actor_roles, uniq: true

  validates :year, presence: true, uniqueness: true, format: {with: /\d{4}/}, length: {is: 4}
  validates :group_stages, presence: true, group_stage: true
  validates :final_stages, presence: true, final_stage: true

  ORDER = [q_column(:year)].freeze
  order_scope :ordered, ORDER

  def group_stages_without_playoffs
    group_stages - MatchInfo::PLAYOFF_STAGES
  end

  # Final stages don't have play off stages at the moment

  def stages
    group_stages + final_stages
  end

  def self.fy year
    find_by_year year.to_s
  end

  # Statistics
  # TODO: Break these out into a separate object, DRY up the code and make them run across all tournaments.

  def characters_by_total_votes
    res = Character.joins(:character_roles => [:series, {:appearances => [:tournament, :match_entries]}])
                   .where(appearances: {tournament_id: self.id}, match_entries: {is_finished: true})
                   .select("#{Series.q_column :id} AS series_id")
                   .select("SUM(#{MatchEntry.q_column :number_of_votes}) as number_of_votes")
                   .select("rank() OVER (ORDER BY SUM(#{MatchEntry.q_column :number_of_votes}) DESC)")
                   .group(Character.q_column :id).group(Series.q_column :id)
                   .order(:rank).merge(Series.ordered).ordered
                   .collect {|r| [r[:rank].to_i, r[:number_of_votes].to_i, r, r[:series_id].to_i]}
    series = {}.tap {|s_hash| Series.find(res.collect(&:last).uniq).each {|s| s_hash[s.id] = s}}
    res.collect {|r| r.push(series[r.pop])}
  end

  def characters_by_average_votes
    res = Character.joins(:character_roles => [:series, {:appearances => [:tournament, :match_entries]}])
                   .where(appearances: {tournament_id: self.id}, match_entries: {is_finished: true})
                   .select("#{Series.q_column :id} AS series_id")
                   .select("AVG(#{MatchEntry.q_column :number_of_votes}) as average_votes")
                   .select("rank() OVER (ORDER BY AVG(#{MatchEntry.q_column :number_of_votes}) DESC)")
                   .group(Character.q_column :id).group(Series.q_column :id)
                   .order(:rank).merge(Series.ordered).ordered
                   .collect {|r| [r[:rank].to_i, r[:average_votes].to_f, r, r[:series_id].to_i]}
    series = {}.tap {|s_hash| Series.find(res.collect(&:last).uniq).each {|s| s_hash[s.id] = s}}
    res.collect {|r| r.push(series[r.pop])}
  end

  def series_by_total_votes
    Series.joins(:character_roles => {:appearances => [:tournament, :match_entries]})
          .where(appearances: {tournament_id: self.id}, match_entries: {is_finished: true})
          .select("SUM(#{MatchEntry.q_column :number_of_votes}) as number_of_votes")
          .select("rank() OVER (ORDER BY SUM(#{MatchEntry.q_column :number_of_votes}) DESC)")
          .group(Series.q_column :id)
          .order(:rank).ordered
          .collect {|r| [r[:rank].to_i, r[:number_of_votes].to_i, r]}
  end
  # TODO: DRY code between character/series_by_total_votes/voice_actors_by_total_votes

  def voice_actors_by_total_votes
    VoiceActor.joins(:voice_actor_roles => {:appearance => [:tournament, :match_entries]})
              .where(appearances: {tournament_id: self.id}, match_entries: {is_finished: true})
              .select("SUM(#{MatchEntry.q_column :number_of_votes}) as number_of_votes")
              .select("rank() OVER (ORDER BY SUM(#{MatchEntry.q_column :number_of_votes}) DESC)")
              .group(VoiceActor.q_column :id)
              .order(:rank).ordered
              .collect {|r| [r[:rank].to_i, r[:number_of_votes].to_i, r]}
  end

  def stages_by_total_votes
    {}.tap do |stage_hash|
      res = Character.joins(:character_roles => [:series, {:appearances => [:tournament, {:match_entries => :match}]}])
                     .where(appearances: {tournament_id: self.id}, match_entries: {is_finished: true})
                     .select("#{Series.q_column :id} AS series_id")
                     .select("#{Match.q_column :stage} AS stage")
                     .select("SUM(#{MatchEntry.q_column :number_of_votes}) as number_of_votes")
                     .select("rank() OVER (PARTITION BY #{Match.q_column :stage} ORDER BY SUM(#{MatchEntry.q_column :number_of_votes}) DESC)")
                     .group(Character.q_column :id).group(Match.q_column :stage).group(Series.q_column :id)
                     .order(:rank).merge(Series.ordered).ordered
                     .collect {|r| [r[:stage].to_sym, r[:rank].to_i, r[:number_of_votes].to_i, r, r[:series_id].to_i]}
      series = {}.tap {|s_hash| Series.find(res.collect(&:last).uniq).each {|s| s_hash[s.id] = s}}
      res.collect {|r| r.push(series[r.pop])}.each do |r|
        stage_hash[r[0]] ||= []
        stage_hash[r[0]] << r[1..-1]
      end
    end
  end

  def stages_by_vote_shares
    {}.tap do |stage_hash|
      res = Character.joins(:character_roles => [:series, {:appearances => [:tournament, {:match_entries => :match}]}])
                     .where(appearances: {tournament_id: self.id}, match_entries: {is_finished: true})
                     .select("#{Series.q_column :id} AS series_id")
                     .select("#{Match.q_column :stage} AS stage")
                     .select("#{MatchEntry.q_column :vote_share} AS vote_share")
                     .select("rank() OVER (PARTITION BY #{Match.q_column :stage} ORDER BY #{MatchEntry.q_column :vote_share} DESC)")
                     .group(Character.q_column :id).group(Match.q_column :stage).group(MatchEntry.q_column :vote_share).group(Series.q_column :id)
                     .order(:rank).merge(Series.ordered).ordered
                     .collect {|r| [r[:stage].to_sym, r[:rank].to_i, r[:vote_share].to_f, r, r[:series_id].to_i]}
      series = {}.tap {|s_hash| Series.find(res.collect(&:last).uniq).each {|s| s_hash[s.id] = s}}
      res.collect {|r| r.push(series[r.pop])}.each do |r|
        stage_hash[r[0]] ||= []
        stage_hash[r[0]] << r[1..-1]
      end
    end
  end

  def stages_by_series_prevalence
    {}.tap do |res|
      Series.joins(:character_roles => {:appearances => [:tournament, {:match_entries => :match}]})
            .where(appearances: {tournament_id: self.id})
            .select("#{Match.q_column :stage} AS stage")
            .select("COUNT(#{MatchEntry.star}) AS number_of_match_entries")
            .select("rank() OVER (PARTITION BY #{Match.q_column :stage} ORDER BY COUNT(#{MatchEntry.star}) DESC)")
            .group(Series.q_column :id).group(Match.q_column :stage)
            .order(:rank).ordered
            .each do |r|
              res[r[:stage].to_sym] ||= []
              res[r[:stage].to_sym] << [r[:rank].to_i, r[:number_of_match_entries].to_i, r]
            end
    end
  end

  def stages_by_voice_actor_prevalence
    {}.tap do |res|
      VoiceActor.joins(:voice_actor_roles => {:appearance => [:tournament, {:match_entries => :match}]})
                .where(appearances: {tournament_id: self.id})
                .select("#{Match.q_column :stage} AS stage")
                .select("COUNT(#{MatchEntry.star}) AS number_of_match_entries")
                .select("rank() OVER (PARTITION BY #{Match.q_column :stage} ORDER BY COUNT(#{MatchEntry.star}) DESC)")
                .group(VoiceActor.q_column :id).group(Match.q_column :stage)
                .order(:rank).ordered
                .each do |r|
                  res[r[:stage].to_sym] ||= []
                  res[r[:stage].to_sym] << [r[:rank].to_i, r[:number_of_match_entries].to_i, r]
                end
    end
  end

end
