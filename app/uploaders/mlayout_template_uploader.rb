require 'carrierwave/orm/datamapper' 
 
class MlayoutTemplateUploader < CarrierWave::Uploader::Base

  #include CarrierWave::RMagick

  storage :file
                                         

  def store_dir   
    TEMP_PATH
  end
  

  def filename


    if original_filename # mLayout 템플릿을 업로드 한 경우에만 적용 
      file_ext_name = ".mlayoutp.zip"
      file_name = original_filename.gsub(file_ext_name,"")

      temp_filename = file_name + file_ext_name
      
      while File.exist?(TEMP_PATH + file_name + file_ext_name)
        
        file_name = file_name + "_1"
        temp_filename = file_name + file_ext_name
  
        temp_filename
      end 
      temp_filename
    end
  end

  def extension_white_list
          %w(mlayoutP zip)
        end

end
