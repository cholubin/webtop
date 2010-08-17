# encoding: utf-8

class PagesController < ApplicationController

  def home
    
    #DB가 완전히 초기화 된 상태에서는 /users/new 를 가장 먼저 방문!    
     #Category.up
     #Subcategory.up
    # 
    
    @title  = "home"
    @menu = "home"
    
    @categories = Category.all(:order => [ :priority.asc ])
    @mytemplates_namecard_best = Temp.all(:category => "명함").best
    @mytemplates_banner_best = Temp.all(:category => "현수막").best
    @freeboards = Freeboard.all(:limit => 4, :order => :created_at.desc)
    @notices = Notice.all(:limit => 4, :order => :created_at.desc)  
    
    #for 세무사 데모 
    # if User.all(:userid => 'test1').count < 1
    #   User.new(:userid =>'test1', :name => 'test1', :password => 'test1', :email=>'test1@iedit.net').save  
    #   User.new(:userid =>'test2', :name => 'test2', :password => 'test2', :email=>'test2@iedit.net').save  
    #   User.new(:userid =>'test3', :name => 'test3', :password => 'test3', :email=>'test3@iedit.net').save  
    #   User.new(:userid =>'test4', :name => 'test4', :password => 'test4', :email=>'test4@iedit.net').save  
    #   User.new(:userid =>'test5', :name => 'test5', :password => 'test5', :email=>'test5@iedit.net').save  
    #   User.new(:userid =>'test6', :name => 'test6', :password => 'test6', :email=>'test6@iedit.net').save  
    #   User.new(:userid =>'test7', :name => 'test7', :password => 'test7', :email=>'test7@iedit.net').save  
    #   User.new(:userid =>'test8', :name => 'test8', :password => 'test8', :email=>'test8@iedit.net').save  
    #   User.new(:userid =>'test9', :name => 'test9', :password => 'test9', :email=>'test9@iedit.net').save  
    #   User.new(:userid =>'test10', :name => 'test10', :password => 'test10', :email=>'test10@iedit.net').save  
    # end 
  end

  def contact
    @title  = "contact"
    @menu = "contact"
  end

  def about
    @title = "about"
    @menu = "about" 
    @categories = Category.all(:order => [:priority])

  end
  
  def tutorial
    @title = "tutorial"
    @menu = "tutorial"
    @categories = Category.all(:order => [:priority])

  end
  
  def test
    @title = "test"
    @menu = "home"
  end
  
  def login
    @title = "login"
    @menu = "home"    
  end 
  
  def logout
 
  end
  
  def congratulations
    @title = "가입완료"
    @menu = "home"
  end
  
  
  def withdraw
    
    if signed_in?
      @users = current_user
      @menu = "home"
      @board = "user"
      @section = "withdraw"

      render 'users/user' 
    else
      redirect_to '/' 
    end
  end 
end
