# encoding: utf-8

class AdminsessionsController < ApplicationController
  
  def new
    Myadmin.up   
    
    @menu = "admin"
    @board = "ad"
    @section = "new"
    
    if admin_signed_in?
      redirect_to admin_users_url
    else    
      render 'admin/adminsessions/new'
    end
  end

  # POST /adminsessions
  # POST /adminsessions.xml
  def create
    
    @menu = "board"
    @board = "adminsession"
    @section = "index"

    
    if params[:adminsession][:admin_id] == "" or params[:adminsession][:password] == ""
      flash.now[:error] = "아이디와 비밀번호를 모두 입력해 주세요!"        
      render 'admin/adminsessions/new'      
    else
      
      @admin = Myadmin.first(:admin_id => params[:adminsession][:admin_id])

      if @admin != nil 
        admin = Myadmin.authenticate(params[:adminsession][:admin_id], 
                             params[:adminsession][:password])
                             
        if admin.nil? 
          flash.now[:error] = "아이디와 비밀번호가 일치하지 않습니다!"
          render 'admin/adminsessions/new'
          
        else
          
          admin_sign_in admin
              
          redirect_to admin_temps_url
          
        end
        
      else
        flash.now[:error] = "존재하지 않는 회원아이디 입니다!"
        render 'admin/adminsessions/new'      
      end
      
    end
    
  end

 

  # DELETE /adminsessions/1
  # DELETE /adminsessions/1.xml
  def destroy
    admin_sign_out
    redirect_to '/admin/login'
  end
end
