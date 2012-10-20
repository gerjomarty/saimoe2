CarrierWave.configure do |config|

  #if Rails.env.test?
  #  config.storage = :file
  #  config.enable_processing = false
  #elsif Rails.env.development?
  #  config.storage = :file
  #else
    config.storage = :fog
    config.root = Rails.root.join('tmp')
    config.cache_dir = 'carrierwave'

    config.fog_directory = ENV['AWS_BUCKET']
    config.fog_credentials = {
        provider: 'AWS',
        aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
        region: 'eu-west-1'
    }
  #end

end