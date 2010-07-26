# encoding: utf-8

class Admin::NoticesController < ApplicationController
  layout "admin_layout"
  before_filter :authenticate_admin!    
        
  # GET /notices
  # GET /notices.xml
  def index
    @menu = "board"
    @board = "notice"
    @section = "index"
    
    @notices_news = Notice.only_news.search(params[:search], params[:page])
    @notices_notices = Notice.only_notice.search(params[:search], params[:page])    
    @total_count = Notice.only_news.search(params[:search],"").count

    
    render 'notice' 
  end

  # GET /notices/1
  # GET /notices/1.xml
  def show
    @notice = Notice.get(params[:id])
    
    if @notice
      @menu = "board"
      @board = "notice"
      @section = "show"
  
      @notice.hit_cnt += 1
      @notice.save
        
      render 'notice'
    else
      redirect_to '/notices'
    end
  end

  # GET /notices/new
  # GET /notices/new.xml
  def new
    @menu = "board"
    @board = "notice"
    @section = "new"
      
    @notice = Notice.new

    render 'notice'
  end

  # GET /notices/1/edit
  def edit
    @menu = "board"
    @board = "notice"
    @section = "edit"
      
    @notice = Notice.get(params[:id])

    render 'notice'  
  end

  # POST /notices
  # POST /notices.xml
  def create
    @menu = "board"
    @board = "notice"

        
    @notice = Notice.new(params[:notice])

      if @notice.save
        redirect_to admin_notices_url
      else
        @section = "new" 
        render 'notice'
      end

  end

  # PUT /notices/1
  # PUT /notices/1.xml
  def update
    @notice = Notice.get(params[:id])

    respond_to do |format|
      if @notice.save(params[:notice])
        format.html { redirect_to(@notice) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @notice.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /notices/1
  # DELETE /notices/1.xml
  def destroy
    
    @notice = Notice.get(params[:id])
    @notice.destroy

    respond_to do |format|
      format.html { redirect_to(admin_notices_url) }
      format.xml  { head :ok }
    end
  end
  
  
  def deleteSelection 


    chk = params[:chk]
    

    if !chk.nil? 
      chk.each do |chk|
        @notice = Notice.get(chk[0].to_i)
        @notice.destroy    
      end
    else
        flash[:notice] = '삭제할 글을 선택하지 않으셨습니다!'    
    end
      
    redirect_to(admin_notices_url)  
   end
   
end

