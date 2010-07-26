# encoding: utf-8

class SessionsController < ApplicationController

  def new
    @menu = "home"
    @board = "session"
    @section = "new"
    
    if signed_in?
      redirect_to '/'
    else    
      render 'session'
    end
  end

  # POST /sessions
  # POST /sessions.xml
  def create
    
    @menu = "board"
    @board = "session"
    @section = "new"

    
    if params[:session][:userid] == "" or params[:session][:password] == ""
      flash.now[:error] = "아이디와 비밀번호를 모두 입력해 주세요!"        
      render 'session'      
    else
      
      @user = User.first(:userid => params[:session][:userid])

      if @user != nil 
        user = User.authenticate(params[:session][:userid], 
                             params[:session][:password])
                             
        if user.nil? 
          flash.now[:error] = "아이디와 비밀번호가 일치하지 않습니다!"
          render 'session'
          
        else
          
          sign_in user
          
          if params[:session][:uri] != ""      
            if params[:session][:uri] == "/users"
              redirect_to '/'
            else
              url = CGI::escape(params[:session][:uri]).gsub(/%2F/,'/').gsub(/%3F/,'?').gsub(/%3D/,'=')
              redirect_to url
            end
          else
            redirect_to '/'
          end
        end
        
      else
        flash.now[:error] = "존재하지 않는 회원아이디 입니다!"
        render 'session'      
      end
      
    end
    
  end

 

  # DELETE /sessions/1
  # DELETE /sessions/1.xml
  def destroy
    sign_out
    redirect_to '/'
  end
end
