# encoding: utf-8
require 'rubygems'
require 'carrierwave/orm/datamapper'   
require 'dm-core'
require 'dm-pager'

$:.unshift File.dirname(__FILE__) + '/../lib'

class Temp
  # Class Configurations ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  include DataMapper::Resource
  mount_uploader :file, MlayoutTemplateUploader
  
  # Attributes ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  property :id,                     Serial
  property :name,                   String
  property :file,                   Text
  property :original_filename,      String, :length => 200
  property :thumb_url,              String, :length => 200
  property :preview_url,            String, :length => 200  
  property :size,                   String 
  property :price,                  String 
      
  property :zip_file,               String, :length => 200
  property :zip_file_path,          String, :length => 200
  property :file_filename,          String, :length => 200
  property :file_filename_encoded,  String, :length => 200  
  
  property :type,                   String 
  property :url,                    String
  property :path,                   String, :length => 200
  property :description,            Text
  property :description_html,       String  
  property :source_path,            String
  property :dest_path,              String
  property :preview_path,           String 
  property :spread_preview_url,     String

  
  property :category,               String
  property :subcategory,            String
  property :tags,                   Text
  property :hit_cnt,                Integer, :default => 0
  property :copy_cnt,               Integer, :default => 0  
  property :is_best,                Boolean, :default => false  

  # for 원플러스 (특정사용자에게만 템플릿 공개)
  property :users,                  Text
       
  # property :included_images,      Array, :default => []     
  # property :images,               Array, :default => []       
  # 

  timestamps :at
  
  before :create, :file_path

  def self.search(search, page)
      Temp.all(:conditions => {:name.like => "%#{search}%"}).page :page => page, :per_page => 12
  end

  def self.search2(search, page)
      Temp.all(:conditions => {:name.like => "%#{search}%"}).page :page => page, :per_page => 6
  end

  
  # for 원플러스 (특정사용자에게만 템플릿 공개)
  def self.isopen(userid)
    if TEMPLATE_OPEN_FUNC_TOGGLE == true
      temp_array = Array.new
      usertempopenlists = Usertempopenlist.all(:user_id => userid)
      i = 0
      usertempopenlists.each do |u|
        temp_array[i] = u.temp_id
        i += 1
      end
      Temp.all(:conditions => {:id => temp_array})
    else
      Temp.all()
    end
  end
  
  def self.best
    Temp.all(:is_best => true)
  end
  
  
  def uploader
    return @uploader if @uploader
    @uploader = MlayoutTemplateUploader.new
    @uploader.retrieve_from_store!(read_attribute(:file))
    # end                                                   
     
  end
  

  def set_dir
      MlayoutTemplateUploader.store_dir = "#{RAILS_ROOT}" + "/public/templates/"
  end
  
      
  def file_path   
    dir = "#{RAILS_ROOT}" + "/public/templates/"
    FileUtils.mkdir_p dir if not File.exist?(dir)
    FileUtils.chmod 0777, dir
    
    return dir 

  end
  
  def filename

    temp_path = "#{RAILS_ROOT}" + "/public/templates/"
    if self.file_filename # 이미지파일을 업로드 한 경우에만 적용 
      @file_ext_name = ".mlayoutP.zip"
      @file_name = self.file_filename.gsub(@file_ext_name,"")

      if File.exist?(temp_path + self.file_filename)
        "#{@file_name}_1#{@file_ext_name}"
      else
        self.file_filename
      end       
    end
  end
      
end

DataMapper.auto_upgrade!

