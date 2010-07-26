# encoding: utf-8
require 'rubygems'
require 'carrierwave/orm/datamapper'   
require 'dm-core'
require 'dm-pager'

$:.unshift File.dirname(__FILE__) + '/../lib'

class Mytemplate
  
  # Class Configurations ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  include DataMapper::Resource
  
  # Attributes ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  property :id,                     Serial
  property :name,                   String
  property :path,                   String, :length => 200
  property :thumb_url,              String, :length => 200
  property :preview_url,            String, :length => 200  
  property :file_filename,          String, :length => 200
  property :type,                   String 
  property :description,            Text

  property :category,               String
  property :subcategory,            String
  property :temp_id,                String

  property :pdf,                    String, :length => 200     
  property :pdf_path,               String, :length => 200       
  property :folder,                 String, :default => "basic"

  timestamps :at
  
  belongs_to :user
    
  before :create, :file_path

  def self.search(search, page)
      Mytemplate.all(:name.like => "%#{search}%").page :page => page, :per_page => 12
  end

  def self.search2(search, page)
      Mytemplate.all(:name.like => "%#{search}%").page :page => page, :per_page => 6
  end
  

  def file_path   
    dir = "#{RAILS_ROOT}" + "/public/user_files/#{self.user.userid}/templates/"
    FileUtils.mkdir_p dir if not File.exist?(dir)
    FileUtils.chmod 0777, dir

    return dir 
  end  

  class << self   
    def process_index_thumbnail(id)
      puts "id: filename? :: " + id
      mytemplate = self.first(:file_filename => id+".zip")

      # tmpl = Temp.get_by_mytemplate_id(mytemplate.id) 
      # path = tmpl.path  
      current_user = User.get(mytemplate.user_id)
      
      base_dir = "#{RAILS_ROOT}" + "/public/user_files/" + current_user.userid + "/article_templates/" + "#{id}" +"/web/"
      # previews = Dir.new(base_dir).entries.sort.delete_if{|x| !(x =~ /jpg$/)}.delete_if{|x| !(x =~ /spread_preview/)}   
      base_url = "#{HOSTING_URL}" + "/user_files/" + current_user.userid + "/article_templates/" + "#{id}" + "/web/"
      puts "base_url: " + base_dir
      index = 1   
      
      reset_imgs(mytemplate)

      previews.each do |spread|  
        stamp = spread[/\_\d\d\d\d\.jpg/].gsub("_","").gsub(".jpg","")
        source_img = base_dir + spread
        preview_filename = spread
        medium_filename = ("spread_medium_000" + (index).to_s + "_" + stamp + ".jpg")
        thumb_filename = ("spread_thumb_000" + (index).to_s + "_" + stamp +".jpg")

        resize_and_write(source_img, base_dir + medium_filename, base_dir + thumb_filename, "medium")
        # resize_and_write(source_img, base_dir + thumb_filename , "thumb")

        # mytemplate.spread_imgs << base_dir + preview_filename
        # mytemplate.spread_imgs_url << base_url + preview_filename
        # mytemplate.spread_mediums << base_dir + medium_filename
        # mytemplate.spread_mediums_url << base_url + medium_filename
        # mytemplate.spread_thumbs << base_dir + thumb_filename
        # mytemplate.spread_thumbs_url << base_url + thumb_filename 
        # @spread_imgs << base_dir + preview_filename
        # @spread_imgs_url << base_url + preview_filename
        # @spread_mediums << base_dir + medium_filename
        # @spread_mediums_url << base_url + medium_filename
        # @spread_thumbs << base_dir + thumb_filename
        # @spread_thumbs_url << base_url + thumb_filename 
        
        index += 1             
      end 
      # mytemplate.spread_imgs = @spread_imgs
      # mytemplate.spread_imgs_url = @spread_imgs_url
      # mytemplate.spread_mediums = @spread_mediums
      # mytemplate.spread_mediums_url = @spread_mediums_url
      # mytemplate.spread_thumbs = @spread_thumbs
      # mytemplate.spread_thumbs_url = @spread_thumbs_url
      
      mytemplate.save 
      return true
    end    
 
    def resize_and_write(source_img, output_medium, output_thumb, size)
      case size
 
      when "medium"
        puts "medium size thumnail making start!==================="
        puts %x[#{RAILS_ROOT}"/lib/thumbup" #{source_img} #{output_medium} 0.5 #{output_thumb} 128]        
        # processed_img = Miso::Image.new(source_img) 
        # processed_img.crop(280, 124) 
        # processed_img.fit(280, 124)
        # processed_img.write(output)            
      when "thumb"
        # processed_img = Miso::Image.new(source_img) 
        # processed_img.crop(140, 62) 
        # processed_img.fit(140, 62)
        # processed_img.write(output)      
      else "error"
        # throw error
      end
    end  
    
    def reset_imgs(mytemplate)
      mytemplate.spread_imgs = nil 
      mytemplate.spread_imgs_url = nil     
      mytemplate.spread_mediums = nil
      mytemplate.spread_mediums_url = nil 
      mytemplate.spread_thumbs = nil
      mytemplate.spread_thumbs_url = nil   
    end
  end # end of << self
      
end

DataMapper.auto_upgrade!

