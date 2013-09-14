# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://www.saimoe.info"
SitemapGenerator::Sitemap.sitemaps_host = "http://#{ENV['AWS_BUCKET']}.s3.amazonaws.com/"
SitemapGenerator::Sitemap.public_path = 'tmp/carrierwave/'
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'
SitemapGenerator::Sitemap.adapter = SitemapGenerator::WaveAdapter.new

SitemapGenerator::Sitemap.create do
  current_tournament = Tournament.all.select {|t| t.currently_on? }.first

  Tournament.find_each do |tournament|
    with_options(changefreq: tournament == current_tournament ? 'daily' : 'monthly') do |o|
      o.add short_tournament_path(tournament.year)
      [:characters_by_total_votes, :characters_by_average_votes, :rounds_by_total_votes, :rounds_by_vote_percentages,
       :series_by_total_votes, :rounds_by_series_prevalence,
       :voice_actors_by_total_votes, :rounds_by_voice_actor_prevalence].each do |action|
        o.add short_tournament_action_path(tournament.year, action)
      end
    end
  end

  add characters_path, priority: 0.7, changefreq: 'monthly'
  add statistics_by_total_votes_characters_path, changefreq: current_tournament ? 'daily' : 'monthly'
  add statistics_by_match_appearances_characters_path, changefreq: current_tournament ? 'daily' : 'monthly'
  add statistics_by_match_wins_characters_path, changefreq: current_tournament ? 'daily' : 'monthly'

  add series_index_path, priority: 0.7, changefreq: 'monthly'
  add statistics_by_total_votes_series_index_path, changefreq: current_tournament ? 'daily' : 'monthly'
  add statistics_by_match_appearances_series_index_path, changefreq: current_tournament ? 'daily' : 'monthly'
  add statistics_by_match_wins_series_index_path, changefreq: current_tournament ? 'daily' : 'monthly'

  add voice_actors_path, priority: 0.7, changefreq: 'monthly'
  add statistics_by_total_votes_voice_actors_path, changefreq: current_tournament ? 'daily' : 'monthly'
  add statistics_by_match_appearances_voice_actors_path, changefreq: current_tournament ? 'daily' : 'monthly'
  add statistics_by_match_wins_voice_actors_path, changefreq: current_tournament ? 'daily' : 'monthly'

  Match.select(Match.q_column :date).uniq.collect(&:date).each do |date|
    add date_path(date.to_s(:number)), changefreq: current_tournament.year.to_i == date.year ? 'daily' : 'monthly'
  end

  Character.find_each do |character|
    add character_path(character), changefreq: current_tournament ? 'daily' : 'monthly'
  end

  Series.find_each do |series|
    add series_path(series), changefreq: current_tournament ? 'daily' : 'monthly'
  end

  VoiceActor.find_each do |voice_actor|
    add voice_actor_path(voice_actor), changefreq: current_tournament ? 'daily' : 'monthly'
  end
end
