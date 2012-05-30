require 'carrierwave/processing/rmagick'
require 'carrierwave/processing/mime_types'

class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MimeTypes
  include CarrierWave::RMagick
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper

  def store_dir
    "avatars"
  end

  def default_url
    asset_path('avatar-defaults/' + ['default', version_name].compact.join('-') + '.png')
  end

  process :set_content_type

  process resize_to_fit: [100, 100]

  version :thumb do
    process resize_to_fit: [40, 40]
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def filename
    @name ||= "#{secure_token}.#{file.extension}" if original_filename.present?
  end

  protected

  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end
end
