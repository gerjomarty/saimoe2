module TournamentsHelper
  def victory_image_path tournament
    %w{png jpg jpeg}.each do |ext|
      path = "victory-images/#{tournament.year}.#{ext}"
      return path if Rails.application.assets.find_asset path
    end
    nil
  end

  def final_stages_cache_key tournament
    "tournament_#{tournament.year}_final"
  end

  def group_stages_all_cache_keys tournament
    tournament.matches.group_matches.select("DISTINCT #{Match.q_column(:group)}").collect(&:group).collect do |g|
      "tournament_#{tournament.year}_group_#{g}"
    end
  end

  def group_stages_cache_key tournament, group
    "tournament_#{tournament.year}_group_#{group}"
  end
end
