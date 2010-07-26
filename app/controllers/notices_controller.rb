# encoding: utf-8

class NoticesController < ApplicationController
  # GET /notices
  # GET /notices.xml
  def index
    @notices_news = Notice.only_news.search(params[:search], params[:page])
    @notices_notice = Notice.only_notice.search(params[:search], params[:page])    
    # puts @articles.inspect
    # puts @articles.count
    @total_count = Notice.only_news.search(params[:search],"").count
    @menu = "board"
    @board = "notice"
    @section = "index"
    

    
# temp = 1
#     100.times { 
#       notice = Notice.new
#       notice.is_notice = false
#       notice.title = "뉴스테스트" + temp.to_s
#       notice.content = "뉴스테스트" + temp.to_s      
#       notice.save
#       temp += 1
#     }
     

    # respond_to do |format|
    #   format.html # index.html.erb
    #   format.xml  { render :xml => @notices }
    # end
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
    @notice = Notice.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @notice }
    end
  end

  # GET /notices/1/edit
  def edit
    @notice = Notice.get(params[:id])
  end

  # POST /notices
  # POST /notices.xml
  def create
    @notice = Notice.new(params[:notice])

    respond_to do |format|
      if @notice.save
        flash[:notice] = 'Notice was successfully created.'
        format.html { redirect_to(@notice) }
        format.xml  { render :xml => @notice, :status => :created, :location => @notice }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @notice.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /notices/1
  # PUT /notices/1.xml
  def update
    @notice = Notice.get(params[:id])

    respond_to do |format|
      if @notice.save(params[:notice])
        flash[:notice] = 'Notice was successfully updated.'
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
      format.html { redirect_to(notices_url) }
      format.xml  { head :ok }
    end
  end
end
