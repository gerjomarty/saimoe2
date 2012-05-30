# This moves the version name to the end of the filename.
# See https://github.com/jnicklas/carrierwave/wiki/How-To%3A-Move-version-name-to-end-of-filename%2C-instead-of-front
module CarrierWave
  module Uploader
    module Versions
      def full_filename(for_file)
        parent_name = super(for_file)
        ext         = File.extname(parent_name)
        base_name   = parent_name.chomp(ext)
        [base_name, version_name].compact.join('-') + ext
      end

      def full_original_filename
        parent_name = super
        ext         = File.extname(parent_name)
        base_name   = parent_name.chomp(ext)
        [base_name, version_name].compact.join('-') + ext
      end
    end
  end
end