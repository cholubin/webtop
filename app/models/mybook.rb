# encoding: utf-8
require 'rubygems'
require 'carrierwave/orm/datamapper'   
require 'dm-core'
require 'dm-pager'

$:.unshift File.dirname(__FILE__) + '/../lib'

class Mybook

  # Class Configurations ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  include DataMapper::Resource
  
  # Attributes ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  property :id,           Serial
  property :name,         String
  property :user_id,      String
  property :folder_name,  String
  property :order,        Integer,  :default => 1
  timestamps :at

  belongs_to :user
  has n, :mybookpdfs    
end

DataMapper.auto_upgrade!