# encoding: utf-8
require 'rubygems'
require 'carrierwave/orm/datamapper'   
require 'dm-core'
require 'dm-validations'
require 'dm-pager'

$:.unshift File.dirname(__FILE__) + '/../lib'

class Myadmin
  
  # Class Configurations ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  include DataMapper::Resource
  attr_accessor :password
  # Attributes ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  property :id,                       Serial
  property :admin_id,                 String, :required => true
  property :name,                     String, :required => true
  property :email,                    String, :required => true


  property :encrypted_password,       String, :length => 150
  property :salt,                     String, :length => 150
  property :ad_remember_token,        Text


  timestamps :at
  
  before :save, :encrypt_password 
  

  def self.up
    if all(:admin_id => "webtop").count < 1
      new(:admin_id => "webtop", :name => "웹탑(관리자)", :email => "webtop@soluwin.co.kr", :password => "5972").save
    end
  end
    
  def has_password?(submitted_password)
      encrypted_password == encrypt(submitted_password)      
  end

  def remember_me!
      # self.ad_remember_token = encrypt("#{salt}--#{id}")  
      self.update(:ad_remember_token => encrypt("#{salt}--#{id}"))

  end
  
  
  def self.search(search, page)
      Myadmin.all(:name.like => "%#{search}%").page :page => page, :per_page => 10
  end
  
  def self.authenticate(admin_id, submitted_password)
    
      admin = Myadmin.first(:admin_id => admin_id)
      
      if admin.nil?
        nil
      elsif admin.has_password?(submitted_password)
        admin
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