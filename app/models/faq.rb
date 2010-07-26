# encoding: utf-8
require 'rubygems'
require 'carrierwave/orm/datamapper'   
require 'dm-core'
require 'dm-pager'

$:.unshift File.dirname(__FILE__) + '/../lib'

class Faq
  
  # Class Configurations ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  include DataMapper::Resource

  
  # Attributes ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  property :id,           Serial
  property :question,     Text
  property :answer,       Text
  property :hit_cnt ,     Integer,  :default => 0  
    
  timestamps :at
  
  def self.search(search, page)
      (Faq.all(:question.like => "%#{search}%") | Faq.all(:answer.like => "%#{search}%")).page :page => page, :per_page => 10
  end
  
end

DataMapper.auto_upgrade!

