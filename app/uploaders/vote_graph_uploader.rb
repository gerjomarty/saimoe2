require 'carrierwave/processing/mime_types'

class VoteGraphUploader < CarrierWave::Uploader::Base
  include CarrierWave::MimeTypes

  def store_dir
    "vote-graphs"
  end

  process :set_content_type

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def filename
    if original_filename.present?
      match_tag = model.group.try(:to_s).try(:downcase) || ''
      match_tag << ("%02d" % model.match_number) if model.match_number
      match_tag.insert(0, '-') unless match_tag.empty?
      @name ||= "#{model.tournament.year}-#{model.stage.to_s.gsub('_', '-')}#{match_tag}.#{file.extension}"
    end
  end
end