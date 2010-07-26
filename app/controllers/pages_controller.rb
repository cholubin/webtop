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
