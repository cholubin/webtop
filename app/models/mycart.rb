# encoding: utf-8
require 'rubygems'
require 'carrierwave/orm/datamapper'   
require 'dm-core'
require 'dm-pager'

$:.unshift File.dirname(__FILE__) + '/../lib'

class Mycart
  
  # Class Configurations ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  include DataMapper::Resource

  # Attributes ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  property :id,             Serial
  property :item_id,        String   
  property :options,        Text
  property :qt,             Integer
  property :unit_price ,    Integer
  property :total_price ,   Integer  


  timestamps :at
  
  belongs_to :user
    
  def self.search(search, page)
      (Mycart.all(:item_name.like => "%#{search}%") | Mycart.all(:options.like => "%#{search}%")).page :page => page, :per_page => 10
  end
  
end

DataMapper.auto_upgrade!

