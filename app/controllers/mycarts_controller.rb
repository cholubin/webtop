# encoding: utf-8

class MycartsController < ApplicationController
    before_filter :authenticate_user!  
  # GET /mycarts
  # GET /mycarts.xml
  def index
    if signed_in? 
      @menu = "home"  
      @board = "mycart"
      @section = "index"
       
      @mycarts = Mycart.all(:user_id => current_user.id)
      render 'mycart'
    else
      redirect_to '/'
    end

    
  end

  # GET /mycarts/1
  # GET /mycarts/1.xml
  def show
    @mycart = Mycart.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mycart }
    end
  end

  # GET /mycarts/new
  # GET /mycarts/new.xml
  def new
    @mycart = Mycart.new()

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mycart }
    end
  end

  # GET /mycarts/1/edit
  def edit
    @mycart = Mycart.find(params[:id])
  end

  # POST /mycarts
  # POST /mycarts.xml
  def create
    
    if signed_in?
      @mycart = Mycart.new  
      # @mytemplate = Mytemplate.first(:id => params[:item_id])

      @mycart.item_id = params[:item_id]
      @mycart.user_id = current_user.id
        
      if @mycart.save
        render :update do |page|
          page.replace_html 'into_cart', :partial => 'into_cart'
        end      
      end
    else
      redirect_to '/'
    end 
  end

  # PUT /mycarts/1
  # PUT /mycarts/1.xml
  def update
    @mycart = Mycart.find(params[:id])

    respond_to do |format|
      if @mycart.update_attributes(params[:mycart])
        flash[:notice] = 'Mycart was successfully updated.'
        format.html { redirect_to(@mycart) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mycart.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mycarts/1
  # DELETE /mycarts/1.xml
  def destroy
    if signed_in?
      @mycart = Mycart.first(:id => params[:id], :user_id => current_user.id)
      @mycart.destroy

      redirect_to mycarts_url
    else
      redirect_to '/'
    end
  end
end
