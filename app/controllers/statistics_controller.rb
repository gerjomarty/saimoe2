class StatisticsController < ApplicationController
  def characters_by_total_votes
    stats = Statistics.new(Character).get_statistic(:total_votes)
    comparison = Statistics.new(Character).get_statistic(:total_votes).before_date(Match.most_recent_finish_date)
    @view_model = StatisticsListViewModel.new(stats, comparison_statistics: comparison)
  end

  def series_by_total_votes
    stats = Statistics.new(Series).get_statistic(:total_votes)
    comparison = Statistics.new(Series).get_statistic(:total_votes).before_date(Match.most_recent_finish_date)
    @view_model = StatisticsListViewModel.new(stats, comparison_statistics: comparison)
  end

  def voice_actors_by_total_votes
    stats = Statistics.new(VoiceActor).get_statistic(:total_votes)
    comparison = Statistics.new(VoiceActor).get_statistic(:total_votes).before_date(Match.most_recent_finish_date)
    @view_model = StatisticsListViewModel.new(stats, comparison_statistics: comparison)
  end
end