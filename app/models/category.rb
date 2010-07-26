# encoding: utf-8
require 'rubygems'
require 'carrierwave/orm/datamapper'   
require 'dm-core'
require 'dm-pager'

class Category
  
  # Class Configurations ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  include DataMapper::Resource

  
  # Attributes ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  property :id,           Serial
  property :name,         String, :required => true
  property :priority,     Integer, :default => 9999
  timestamps :at

  has n, :subcategories

  def self.up
    if Category.first(:name => '명함') == nil
      Category.new(:name=>'명함', :priority=>1).save
      Category.new(:name=>'현수막', :priority=>2).save
      Category.new(:name=>'봉투', :priority=>3).save  
    else 
      puts Category.first(:priority => 1).id
    end
  end
end



class Subcategory

  # Class Configurations ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  include DataMapper::Resource

  
  # Attributes ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  property :id,           Serial
  property :name,         String, :required => true
  property :priority,     Integer, :default => 9999
      
  timestamps :at

  belongs_to :category

  def self.up
    
    if Subcategory.first(:name => '기업명함') == nil
      Subcategory.new(:name=>'기업명함', :priority=>1, :category_id=>Category.first(:priority => 1).id).save
      Subcategory.new(:name=>'디자인명함', :priority=>2, :category_id=>Category.first(:priority => 1).id).save
      Subcategory.new(:name=>'일반명함', :priority=>3, :category_id=>Category.first(:priority => 1).id).save
      Subcategory.new(:name=>'고급명함', :priority=>4, :category_id=>Category.first(:priority => 1).id).save       
      Subcategory.new(:name=>'카드명함', :priority=>5, :category_id=>Category.first(:priority => 1).id).save             
      
      Subcategory.new(:name=>'비즈니스', :priority=>1, :category_id=>Category.first(:priority => 2).id).save
      Subcategory.new(:name=>'공공기관', :priority=>2, :category_id=>Category.first(:priority => 2).id).save
      Subcategory.new(:name=>'의료', :priority=>3, :category_id=>Category.first(:priority => 2).id).save
      Subcategory.new(:name=>'종교', :priority=>4, :category_id=>Category.first(:priority => 2).id).save
      
      Subcategory.new(:name=>'칼라소봉투', :priority=>1, :category_id=>Category.first(:priority => 3).id).save
      Subcategory.new(:name=>'자켓형소봉투', :priority=>2, :category_id=>Category.first(:priority => 3).id).save
      Subcategory.new(:name=>'칼라중봉투', :priority=>3, :category_id=>Category.first(:priority => 3).id).save
      Subcategory.new(:name=>'칼라대봉투', :priority=>4, :category_id=>Category.first(:priority => 3).id).save                 
    else 
      puts Subcategory.all.inspect
    end
  end
    
end


DataMapper.auto_upgrade!