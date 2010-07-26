class Admin::MybooksController < ApplicationController
  # GET /admin_mybooks
  # GET /admin_mybooks.xml
  def index
    @admin_mybooks = Admin::Mybook.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @admin_mybooks }
    end
  end

  # GET /admin_mybooks/1
  # GET /admin_mybooks/1.xml
  def show
    @mybook = Admin::Mybook.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mybook }
    end
  end

  # GET /admin_mybooks/new
  # GET /admin_mybooks/new.xml
  def new
    @mybook = Admin::Mybook.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mybook }
    end
  end

  # GET /admin_mybooks/1/edit
  def edit
    @mybook = Admin::Mybook.find(params[:id])
  end

  # POST /admin_mybooks
  # POST /admin_mybooks.xml
  def create
    @mybook = Admin::Mybook.new(params[:mybook])

    respond_to do |format|
      if @mybook.save
        flash[:notice] = 'Admin::Mybook was successfully created.'
        format.html { redirect_to(@mybook) }
        format.xml  { render :xml => @mybook, :status => :created, :location => @mybook }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mybook.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin_mybooks/1
  # PUT /admin_mybooks/1.xml
  def update
    @mybook = Admin::Mybook.find(params[:id])

    respond_to do |format|
      if @mybook.update_attributes(params[:mybook])
        flash[:notice] = 'Admin::Mybook was successfully updated.'
        format.html { redirect_to(@mybook) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mybook.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin_mybooks/1
  # DELETE /admin_mybooks/1.xml
  def destroy
    @mybook = Admin::Mybook.find(params[:id])
    @mybook.destroy

    respond_to do |format|
      format.html { redirect_to(admin_mybooks_url) }
      format.xml  { head :ok }
    end
  end
end
