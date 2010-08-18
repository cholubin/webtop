# encoding: utf-8
require 'rubygems'
require 'carrierwave/orm/datamapper'   
require 'dm-core'
require 'dm-validations'
require 'dm-pager'

$:.unshift File.dirname(__FILE__) + '/../lib'

class User
  
  # Class Configurations ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  include DataMapper::Resource
  attr_accessor :password
  
  # Attributes ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  property :id,                 Serial
  property :userid,             String, :required => true
  property :name,               String, :required => true
  property :email,              String, :required => true

  property :encrypted_password, String, :length => 150
  property :salt,               String, :length => 150
  property :remember_token,     Text,   :length => 150

  property :withdrawal_reason,  Text
  timestamps :at
  
  has n, :mybooks
  has n, :mytemplates
  has n, :freeboards
  has n, :myimages
  has n, :mycarts
  has n, :mypdfs 
  before :save, :encrypt_password
  before :create, :pdf_path
  after  :save, :demo_up

  def pdf_path

        
    dir = "#{RAILS_ROOT}" + "/public/user_files/#{self.userid}/pdfs"
    FileUtils.mkdir_p dir if not File.exist?(dir)
    FileUtils.chmod 0777, dir
    
    dir = "#{RAILS_ROOT}" + "/public/user_files/#{self.userid}/images/photo/Thumb"
    FileUtils.mkdir_p dir if not File.exist?(dir)
    FileUtils.chmod 0777, dir

    dir = "#{RAILS_ROOT}" + "/public/user_files/#{self.userid}/images/photo/Preview"
    FileUtils.mkdir_p dir if not File.exist?(dir)
    FileUtils.chmod 0777, dir
  
    
    dir = "#{RAILS_ROOT}" + "/public/user_files/#{self.userid}/images/photo"
    FileUtils.mkdir_p dir if not File.exist?(dir)
    FileUtils.chmod 0777, dir
    
    
    MyimageUploader.store_dir = dir    
    return dir    
  end

  def demo_up
    begin
      if Folder.all(:name => 'basic_photo', :user_id => self.id.to_s).count < 1
        Folder.new(:name => 'basic_photo', :user_id => self.id.to_s).save
        
        Myimage.new(:image_filename=>'1.JPG', :image_thumb_filename => '1.JPG', :name => '1', :user_id => self.id, :folder => 'basic_photo').save
        Myimage.new(:image_filename=>'2.JPG', :image_thumb_filename => '2.JPG', :name => '2', :user_id => self.id, :folder => 'basic_photo').save      
        Myimage.new(:image_filename=>'3.JPG', :image_thumb_filename => '3.JPG', :name => '3', :user_id => self.id, :folder => 'basic_photo').save            
        Myimage.new(:image_filename=>'4.JPG', :image_thumb_filename => '4.JPG', :name => '4', :user_id => self.id, :folder => 'basic_photo').save                  
        Myimage.new(:image_filename=>'5.JPG', :image_thumb_filename => '5.JPG', :name => '5', :user_id => self.id, :folder => 'basic_photo').save                  
        Myimage.new(:image_filename=>'6.JPG', :image_thumb_filename => '6.JPG', :name => '6', :user_id => self.id, :folder => 'basic_photo').save                  
        Myimage.new(:image_filename=>'7.JPG', :image_thumb_filename => '7.JPG', :name => '7', :user_id => self.id, :folder => 'basic_photo').save                  
        Myimage.new(:image_filename=>'8.JPG', :image_thumb_filename => '8.JPG', :name => '8', :user_id => self.id, :folder => 'basic_photo').save                  
        Myimage.new(:image_filename=>'9.JPG', :image_thumb_filename => '9.JPG', :name => '9', :user_id => self.id, :folder => 'basic_photo').save                  
        Myimage.new(:image_filename=>'10.JPG', :image_thumb_filename => '10.JPG', :name => '10', :user_id => self.id, :folder => 'basic_photo').save                  
        Myimage.new(:image_filename=>'11.JPG', :image_thumb_filename => '11.JPG', :name => '11', :user_id => self.id, :folder => 'basic_photo').save                  
        Myimage.new(:image_filename=>'12.JPG', :image_thumb_filename => '12.JPG', :name => '12', :user_id => self.id, :folder => 'basic_photo').save                  
        Myimage.new(:image_filename=>'13.JPG', :image_thumb_filename => '13.JPG', :name => '13', :user_id => self.id, :folder => 'basic_photo').save                  
        puts_message "building basic photo db for demo"
      end
    rescue
      puts_message "error!!!"
    end
    
    
  end
  
  def has_password?(submitted_password)
      encrypted_password == encrypt(submitted_password)      
  end

  def remember_me!
      # self.remember_token = encrypt("#{salt}--#{id}")  
      self.update(:remember_token => encrypt("#{salt}--#{id}"))

  end
  
  
  def self.search(search, page)
      User.all(:name.like => "%#{search}%").page :page => page, :per_page => 10
  end
  
  def self.authenticate(userid, submitted_password)
    
      user = User.first(:userid => userid)
      
      if user.nil?
        nil
      elsif user.has_password?(submitted_password)
        user
      end
  end

   private

       def encrypt_password
         if self.encrypted_password.nil?
           self.salt = make_salt
           self.encrypted_password = encrypt(password)
         end
       end

       def encrypt(string)
         secure_hash("#{salt}#{string}")
       end

       def make_salt
         secure_hash("#{Time.now.utc}#{password}")
       end

       def secure_hash(string)
         Digest::SHA2.hexdigest(string)
       end
           

  
  
end

DataMapper.auto_upgrade!