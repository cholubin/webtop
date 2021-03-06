# encoding: utf-8
require 'rubygems'
require 'carrierwave/orm/datamapper'   
require 'dm-core'
require 'dm-pager'

  $:.unshift File.dirname(__FILE__) + '/../lib'
class Mypdf

  # Class Configurations ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  include DataMapper::Resource

  # Attributes ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  property :pdf_filename,           String, :length => 200    

  property :id,                     Serial
  property :name,                   String
  property :description,            Text,     :lazy => [ :show ]


  timestamps :at
  
  belongs_to :user

  before :save, :pdf_path

  def pdf_path
    dir = "#{RAILS_ROOT}" + "/public/user_files/#{self.user.userid}/pdfs"
    FileUtils.mkdir_p dir if not File.exist?(dir)
    FileUtils.chmod 0777, dir
  end
  
  
  def self.search(search, page)
      (Mypdf.all(:name.like => "%#{search}%") | Mypdf.all(:description.like => "%#{search}%")).page :page => page, :per_page => 12
  end

  def basic_path
    if not self.user.nil?
      return "#{RAILS_ROOT}" + "/public/user_files/#{self.user.userid}/pdfs/"
    end
  end

  def basic_url
    if not self.user.nil?
      return "#{HOSTING_URL}" + "user_files/#{self.user.userid}/pdfs/"
    end
  end

  def thumb_url
    if not self.user.nil?
      "#{HOSTING_URL}" + "user_files/#{self.user.userid}/pdfs/#{self.pdf_filename.gsub(/.pdf/,'') +"_t"+".jpg"}"
    end
  end

  def thumb_path
    if not self.user.nil?
      "#{RAILS_ROOT}" + "/public/user_files/#{self.user.userid}/pdfs/#{self.pdf_filename.gsub(/.pdf/,'') +"_t"+".jpg"}"
    end
  end
  
  def preview_url
    if not self.user.nil?
      "#{HOSTING_URL}" + "user_files/#{self.user.userid}/pdfs/#{self.pdf_filename.gsub(/.pdf/,'') +"_p"+".jpg"}"
    end
  end

  def preview_path
    if not self.user.nil?
      "#{RAILS_ROOT}" + "/public/user_files/#{self.user.userid}/pdfs/#{self.pdf_filename.gsub(/.pdf/,'') +"_p"+".jpg"}"
    end
  end
  
  def pdf_url
    if not self.user.nil?
      "#{HOSTING_URL}" + "user_files/#{self.user.userid}/pdfs/#{self.pdf_filename}"
    end
  end


end

DataMapper.auto_upgrade!