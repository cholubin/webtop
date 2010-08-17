# encoding: utf-8

class UsersController < ApplicationController
  # GET /users
  # GET /users.xml
  def index
    @users = User.search(params[:search], params[:page])
    @total_count = User.search(params[:search],"").count
        
    @menu = "home"
    @board = "user"
    @section = "index"
    
    render 'user'
  end

  # GET /users/1
  # GET /users/1.xml
  def show

    @user = User.get(params[:id])
        
    if signed_in? && @user.id == current_user.id
      @menu = "home"
      @board = "user"
      @section = "show"
    
      render 'user'
    else
      redirect_to '/'
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new

    @menu = "home"
    @board = "user"
    @section = "new"
    
    render 'user'
    
  end

  # GET /users/1/edit
  def edit
    @user = User.get(params[:id])
        
    if signed_in? && @user.id == current_user.id
      @menu = "home"
      @board = "user"
      @section = "edit"

      render 'user'
    else
      redirect_to '/'
    end
    
  end

  # POST /users
  # POST /users.xml
  def create

    @menu = "home"
    @board = "user"
        
    @user = User.new
    @user.userid = params[:user][:userid]
    @user.name = params[:user][:name]
    @user.password = params[:user][:password]
    @user.email = params[:user][:email]
    
    flash[:notice] = "<ul>"
    
    if params[:user][:userid] == ""
      flash[:notice] += "<li>사용자 아이디를 입력하세요.</li>"
    end

    if params[:user][:name] == ""
      flash[:notice] += "<li>사용자 이름을 입력하세요.</li>"      
    end

    if params[:user][:password] == ""
      flash[:notice] += "<li>비밀번호를 입력하세요.</li>"      
    end

    if params[:user][:email] == ""
      flash[:notice] += "<li>이메일 주소를 입력하세요.</li>"      
    end
    
    
    
    if @user.userid == nil or @user.name == nil or @user.password == nil or @user.email == nil
      @section = "new"        
      flash[:notice] += "</ul>"     
      render 'user' 
    else
        if not User.first(:userid => params[:user][:userid]).nil? # 아이디 중복인 경우 ========================== 
          flash[:notice] += "<li>이미 사용하고 있는 아이디 입니다.</li>"
          flash[:notice] += "</ul>"       
          @section = "new"        
          render 'user'    
        else
          if @user.save
            @section = "index"
            sign_in @user
            render 'pages/congratulations'

          else
            @section = "new"        
            render 'user'
          end      
        end
    end
        


  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.get(params[:id])

    if signed_in? && @user.id == current_user.id
      @menu = "home"
      @board = "user"
      @section = "edit"
    
      if params[:user][:new_password] != ""

        if params[:user][:current_password] == @user.password
          @user.password = params[:user][:new_password]
          @user.email = parmas[:user][:email]
        
          if @user.save
            render 'users/modificaton_finished'  
          else
            flash[:notice] = "오류가 발생했습니다. 다시 시도해주시기 바랍니다."
            render 'user'
          end

        else
          flash[:notice] = "비밀번호가 틀립니다! 다시입력해 주세요."
          render 'user'
        end    
      
      else  #메일만 수정하는 경우       
        @user.email = params[:user][:email]
      
        if @user.save
          render 'users/modification_finished'  
        else
          flash[:notice] = "오류가 발생했습니다. 다시 시도해주시기 바랍니다."
          render 'user'
        end 
           
      end
      
    else
      redirect_to '/'
    end
      

  end



  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    
    @user = User.get(params[:id])
    
    if signed_in? && current_user.id == @user.id

      user_dir = "#{RAILS_ROOT}" + "/public/user_files/#{current_user.userid}/"
      FileUtils.rm_rf user_dir
      
      begin
        @mycarts = Mycart.all(:user_id => current_user.id)  
        @mycarts.destroy

        @freeboards = Freeboard.all(:user_id => current_user.id)  
        @freeboards.destroy
      
        @mytemplates = Mytemplate.all(:user_id => current_user.id)
        @mytemplates.destroy
      
        @myimages = Myimage.all(:user_id => current_user.id)  
        @myimages.destroy

        @usertempopenlists = Usertempopenlist.all(:user_id => current_user.id)
        @usertempopenlists.destroy
      rescue
        puts_message "사용자 관련 테이블 삭제 진행중 오류 발생!"
      end
      
      if @user.destroy
      else
        puts_message "사용자 테이블 삭제 진행중 오류 발생!"
        puts @user.errors
      end
            
      sign_out

            
      @menu = "home"
      @board = "user"
      @section = "edit"
      
      render 'users/withdrawal_finished'
      # render '/users/withdrawal_finished'  이경우에는 users컨트롤러가 아닌 users폴더내의 템플릿을 참고하게 된다. 즉 기본 레이아웃을 가져오지 않는다.
    else
      redirect_to '/'
    end
  end
  
  
  def id_check

      # 중복아이디 체크 
     @user = User.first(:userid => params[:user_id])
     # puts @user.name

     render :update do |page|
       page.replace_html 'id_check', :partial => 'id_check', :object => @user
     end   

  end
    
end
