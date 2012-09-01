module TournamentsHelper
  def victory_image_path tournament
    %w{png jpg jpeg}.each do |ext|
      path = "victory-images/#{tournament.year}.#{ext}"
      return path if Rails.application.assets.find_asset path
    end
    nil
  end
end
