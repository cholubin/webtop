class MyimageUploader < CarrierWave::Uploader::Base

  # Include RMagick or ImageScience support
  #    include CarrierWave::RMagick
  #     include CarrierWave::ImageScience

  # Choose what kind of storage to use for this uploader
  storage :file
  #     storage :s3

  # Override the directory where uploaded files will be stored
  # This is a sensible default for uploaders that are meant to be mounted:
  # def store_dir
  #   puts "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  #   "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  # end
  
  # def store_dir
  #   if model.user_id.nil?
  #      "#{RAILS_ROOT}" + "/public/user_files/images/"
  #    
  #    else
  #     "#{RAILS_ROOT}" + "/public/user_files/#{User.get(:id => model.user_id)}/images/"
  #   
  #   end
  #   
  # 
  # end


  # Provide a default URL as a default if there hasn't been a file uploaded
  #     def default_url
  #       "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  #     end

  # Process files as they are uploaded.
  #     process :scale => [200, 300]
  #
  #     def scale(width, height)
  #       # do something
  #     end

  # version :t do
  #   def store_dir
  #     # puts "여기 들어오긴 하냐> "
  #     #     puts "uploads/#{model.id}"
  #     #     "#{RAILS_ROOT}" + "/public/user_files/cholubin/images/"
  #     model.set_dir
  #   end
  #   
  #   process :resize_to_fit => [167,94]
  #   
  # end

  def extension_white_list
      %w(jpg jpeg gif png pdf eps)
  end

  def filename

    if original_filename # 이미지파일을 업로드 한 경우에만 적용 
      @file_ext_name = File.extname(original_filename).downcase
      @file_name = original_filename.gsub(@file_ext_name,"")

      @temp_filename = @file_name + @file_ext_name
    
      puts model.image_path + "/" + @file_name + @file_ext_name      
      
      while File.exist?(model.image_path + "/" + @file_name + @file_ext_name)

        @file_name = @file_name + "_1"
        @temp_filename = @file_name + @file_ext_name
        
        @temp_filename
        
      end 
      puts "@temp_filename::::::" + @temp_filename
      @temp_filename
    end

  end

end
