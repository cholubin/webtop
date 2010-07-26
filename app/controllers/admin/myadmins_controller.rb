# encoding: utf-8

class Admin::MyadminsController < ApplicationController
  layout 'admin_layout'
  # GET /myadmins
  # GET /myadmins.xml
  def index
    
    @menu = "admin"
    @board = "admin"
    @section = "index"
        
    @myadmins = Myadmin.search(params[:search], params[:page])
    @total_count = Myadmin.search(params[:search],"").count
    
    render 'myadmin'
  end

  # GET /myadmins/1
  # GET /myadmins/1.xml
  def show
    @menu = "admin"
    @board = "admin"
    @section = "show"
    
    @myadmin = Myadmin.get(params[:id].to_i)

    render 'myadmin'
  end

  # GET /myadmins/new
  # GET /myadmins/new.xml
  def new
    @menu = "admin"
    @board = "admin"
    @section = "new"
    
    @myadmin = Myadmin.new

    render 'myadmin'
  end

  # GET /myadmins/1/edit
  def edit
    @menu = "admin"
    @board = "admin"
    @section = "edit"
    
    @myadmin = Myadmin.get(params[:id])

    render 'myadmin'    
  end

  # POST /myadmins
  # POST /myadmins.xml
  def create
    @menu = "home"
    @board = "admin"
    @section = "new"

    @myadmin = Myadmin.new

    @myadmin.admin_id = params[:admin][:admin_id]
    @myadmin.name = params[:admin][:name]
    @myadmin.password = params[:admin][:password]
    @myadmin.email = params[:admin][:email]
    
    flash[:notice] = "<ul>"
    
    if params[:admin][:admin_id] == ""
      flash[:notice] += "<li>사용자 아이디를 입력하세요.</li>"
    end

    if params[:admin][:name] == ""
      flash[:notice] += "<li>사용자 이름을 입력하세요.</li>"      
    end

    if params[:admin][:password] == ""
      flash[:notice] += "<li>비밀번호를 입력하세요.</li>"      
    end

    if params[:admin][:email] == ""
      flash[:notice] += "<li>이메일 주소를 입력하세요.</li>"      
    end
    
    
    
    if @myadmin.admin_id == nil or @myadmin.name == nil or @myadmin.password == nil or @myadmin.email == nil
      flash[:notice] += "</ul>"     
      render 'myadmin' 
      
    else

        if not Myadmin.get(:admin_id => params[:admin][:admin_id]).nil? # 아이디 중복인 경우 ========================== 
          flash[:notice] += "<li>이미 사용하고 있는 아이디 입니다.</li>"
          flash[:notice] += "</ul>"       
          @section = "new"        
          render 'myadmin'    
        else
          if @myadmin.save
            redirect_to '/myadmins'

          else
            @section = "new"        
            render 'myadmin'
          end      
        end
    end
  end

  # PUT /myadmins/1
  # PUT /myadmins/1.xml
  def update
    @myadmin = Myadmin.get(params[:id])

    respond_to do |format|
      if @myadmin.update_attributes(params[:myadmin])
        flash[:notice] = 'Myadmin was successfully updated.'
        format.html { redirect_to(@myadmin) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @myadmin.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /myadmins/1
  # DELETE /myadmins/1.xml
  def destroy
    @myadmin = Myadmin.get(params[:id].to_i)
    @myadmin.destroy

    respond_to do |format|
      format.html { redirect_to(myadmins_url) }
      format.xml  { head :ok }
    end
  end
  
  def id_check

      # 중복아이디 체크 
     @admin = Myadmin.first(:admin_id => params[:admin_id])
     # puts @admin.name

     render :update do |page|
       page.replace_html 'id_check', :partial => 'admin/myadmins/id_check', :object => @admin
     end   

  end  
  
  # multiple deletion
  def deleteSelection 

    chk = params[:chk]

    if !chk.nil? 
      chk.each do |chk|
        @myadmin = Myadmin.get(chk[0].to_i)
        @myadmin.destroy    
      end
    else
        flash[:notice] = '삭제할 글을 선택하지 않으셨습니다!'    
    end
      
    redirect_to(admin_myadmins_url)  
   end  
end
