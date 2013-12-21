require 'carrierwave/processing/mime_types'

class SeriesImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MimeTypes
  include CarrierWave::RMagick

  def store_dir
    "series-images"
  end

  process convert: 'png'

  process :set_content_type

  version :normal do
    process resize_to_fit: [200, 200]
  end

  def extension_white_list
    %w(jpg jpeg gif png ico)
  end

  def filename
    @name ||= "#{secure_token}.png" if original_filename.present?
  end

  protected

  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end
end