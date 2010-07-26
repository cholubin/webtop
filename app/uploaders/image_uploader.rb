
class ImageUploader < CarrierWave::Uploader::Base


  # Include RMagick or ImageScience support
  #    include CarrierWave::RMagick
  #     include CarrierWave::ImageScience

  # Choose what kind of storage to use for this uploader
  storage :file
  #     storage :s3

  # Override the directory where uploaded files will be stored
  # This is a sensible default for uploaders that are meant to be mounted:
  
  def store_dir   
    dir = IMAGE_PATH
    FileUtils.mkdir_p dir if not File.exist?(dir)
    FileUtils.chmod 0777, dir
    return dir 
    # "#{RAILS_ROOT}/public/user_files/images/"
  end
  
  def set_store_dir= (path)
      CarrierWave.config[:store_dir] = path
  end

  # Provide a default URL as a default if there hasn't been a file uploaded
  #     def default_url
  #       "/images/fallback/" + [version_name, "default.jpg"].compact.join('_')
  #     end

  # Process files as they are uploaded.
  #     process :scale => [200, 300]
  #
      # def scale(width, height)
      #   # do something
      # end

  # Create different versions of your uploaded files

       
  version :t do
    process :resize_to_fit => [167,94]
  end
  

  
  # version :thumb do
  #     process :resize_to_fill => [50, 50]
  #   end
  
  # Add a white list of extensions which are allowed to be uploaded,
  # for images you might use something like this:
  def extension_white_list
      %w(jpg jpeg gif png pdf)
  end

  # Override the filename of the uploaded files
  #     def filename
  #       "something.jpg" if original_filename
  #     end
  
  # filename을 Base64의 encode64로 인코딩한다. ::::::::::::::::::::::::::::::::::::::::::::::::::
  # carroerwave는 sanitize하기전 진짜 original_filename을 가지고 있지 않다.
  
 # 업로드 처리단에서 정제된 한글파일명으로 리네임처리 함으로 필요없게 되었다. =============================================
  def filename

    if original_filename # 이미지파일을 업로드 한 경우에만 적용 
      @file_ext_name = File.extname(original_filename).downcase
      @file_name = original_filename.gsub(@file_ext_name,"")
        
      if File.exist?(IMAGE_PATH + original_filename) and File.exist?(IMAGE_PATH + "t_" +  original_filename) 
        "#{@file_name}_1#{@file_ext_name}"
      else
        original_filename
      end       
    end
  end 
 

     
     
  # def filename
  #     
  #     "#{filename}#{File.extname(original_filename).downcase}" if original_filename
  #   end
  #   
end
