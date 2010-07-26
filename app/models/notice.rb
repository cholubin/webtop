# encoding: utf-8
require 'rubygems'
require 'carrierwave/orm/datamapper'   
require 'dm-core'
require 'dm-pager'

$:.unshift File.dirname(__FILE__) + '/../lib'

class Notice
  
  # Class Configurations ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  include DataMapper::Resource

  
  # Attributes ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  property :id,           Serial
  property :title,        String
  property :content,      Text
  property :hit_cnt ,     Integer, :default => 0
  property :is_notice,    Boolean
  
  
  timestamps :at
  
  def self.search(search, page)
      (Notice.all(:title.like => "%#{search}%") | Notice.all(:content.like => "%#{search}%")).page :page => page, :per_page => 10
  end
  
  def self.only_notice
    Notice.all(:is_notice => true)
  end
  
  def self.only_news
    Notice.all(:is_notice => false)
  end
end

DataMapper.auto_upgrade!

