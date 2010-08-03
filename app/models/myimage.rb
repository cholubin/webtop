# encoding: utf-8
require 'rubygems'
require 'carrierwave/orm/datamapper'   
require 'dm-core'
require 'dm-pager'

$:.unshift File.dirname(__FILE__) + '/../lib'

class Myimage
  
  # Class Configurations ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  include DataMapper::Resource
  mount_uploader :image_file, MyimageUploader
  
  # Attributes ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  property :image_file,                 Text,     :default => "no_image"
  property :image_filename,             String,   :length => 200  
  property :image_thumb_filename,       String,   :length => 200    
  property :image_filename_encoded,     String,   :length => 200
      
  property :id,                         Serial
  property :name,                       String
  property :description,                Text,     :lazy => [ :show ]
  property :tags,                       Text,     :lazy => [ :show ]
  property :type,                       String,   :default => "jpg"
  
  property :folder,                     String,   :default => "photo"
  

  timestamps :at
  
  belongs_to :user
  before :create, :image_path

  
  def self.search_user(search, page)
      (Myimage.all(:name.like => "%#{search}%") | Myimage.all(:tags.like => "%#{search}%")).page :page => page, :per_page => 12
  end

  def self.search(search, page)
      (Myimage.all(:name.like => "%#{search}%") | Myimage.all(:tags.like => "%#{search}%")).page :page => page, :per_page => 10
  end
  
  def set_dir
    if not self.user.nil?
      MyimageUploader.store_dir = "#{RAILS_ROOT}" + "/public/user_files/#{self.user.userid}/images/"
    end
  end
  
  def url
    if not self.user.nil?
      "#{HOSTING_URL}" + "user_files/#{self.user.userid}/images/#{self.folder}/#{self.image_filename}"
    end
  end

  def thumb_url
    if not self.user.nil?
      "#{HOSTING_URL}" + "user_files/#{self.user.userid}/images/#{self.folder}/Thumb/#{self.image_thumb_filename}"
    end
  end

  def preview_url
    if not self.user.nil?
      "#{HOSTING_URL}" + "user_files/#{self.user.userid}/images/#{self.folder}/Preview/#{self.image_thumb_filename}"
    end
  end

      
  def image_path

    dir1 = "#{RAILS_ROOT}" + "/public/user_files/#{self.user.userid}/images/photo/Thumb"
    FileUtils.mkdir_p dir1 if not File.exist?(dir1)
    FileUtils.chmod 0777, dir1

    dir1 = "#{RAILS_ROOT}" + "/public/user_files/#{self.user.userid}/images/photo/Preview"
    FileUtils.mkdir_p dir1 if not File.exist?(dir1)
    FileUtils.chmod 0777, dir1
  
    
    dir = "#{RAILS_ROOT}" + "/public/user_files/#{self.user.userid}/images/photo"
    FileUtils.mkdir_p dir if not File.exist?(dir)
    FileUtils.chmod 0777, dir
    
    MyimageUploader.store_dir = dir    
    return dir 
    
  end

  def image_folder(folder)
    dir1 = "#{RAILS_ROOT}" + "/public/user_files/#{self.user.userid}/images/#{folder}/Thumb"
    FileUtils.mkdir_p dir1 if not File.exist?(dir1)
    FileUtils.chmod 0777, dir1

    dir1 = "#{RAILS_ROOT}" + "/public/user_files/#{self.user.userid}/images/#{folder}/Preview"
    FileUtils.mkdir_p dir1 if not File.exist?(dir1)
    FileUtils.chmod 0777, dir1
  
    
    dir = "#{RAILS_ROOT}" + "/public/user_files/#{self.user.userid}/images/#{folder}"
    FileUtils.mkdir_p dir if not File.exist?(dir)
    FileUtils.chmod 0777, dir
    return dir 
  end

    
  def filename

    image_path = "#{RAILS_ROOT}" + "/public/user_files/#{self.user.userid}/images/photo/"
    if original_filename # 이미지파일을 업로드 한 경우에만 적용 
      @file_ext_name = File.extname(original_filename).downcase
      @file_name = original_filename.gsub(@file_ext_name,"")

      if File.exist?(image_path + original_filename)
        "#{@file_name}_1#{@file_ext_name}"
      else
        original_filename
      end       
    end
  end
      
end

DataMapper.auto_upgrade!

