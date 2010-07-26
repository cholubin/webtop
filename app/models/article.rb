# encoding: utf-8
require 'rubygems'
require 'carrierwave/orm/datamapper'   
require 'dm-core'
require 'dm-pager'

$:.unshift File.dirname(__FILE__) + '/../lib'

class Article
  
  # Class Configurations ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  include DataMapper::Resource
  mount_uploader :image_file, ImageUploader
  
  # Attributes ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  property :id,                       Serial
  property :title,                    String, :length => 200, :required => true
  property :body,                     Text,   :required => true
  
  property :image_file,               Text,   :default => "no_image"
  property :image_filename,           String, :length => 200
  property :image_filename_encoded,   String, :length => 200

    
  timestamps :at
  

  def self.search(search, page)
      Article.all(:conditions => {:title.like => "%#{search}%"}).page :page => page, :per_page => 10
  end
  
end

DataMapper.auto_upgrade!

