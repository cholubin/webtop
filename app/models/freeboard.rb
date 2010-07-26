# encoding: utf-8
require 'rubygems'
require 'carrierwave/orm/datamapper'   
require 'dm-core'
require 'dm-pager'

$:.unshift File.dirname(__FILE__) + '/../lib'

class Freeboard
  
  # Class Configurations ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  include DataMapper::Resource

  
  # Attributes ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  property :id,           Serial
  property :title,        Text,     :required => true
  property :content,      Text,     :lazy => [ :show ]
  property :tags,         Text,     :lazy => [ :show ]
  property :hit_cnt ,     Integer,  :default => 0
  

  timestamps :at
  
  belongs_to :user
    
  def self.search(search, page)
      (Freeboard.all(:title.like => "%#{search}%") | Freeboard.all(:content.like => "%#{search}%")).page :page => page, :per_page => 10
  end
  
end

DataMapper.auto_upgrade!

