class MybookpdfsController < ApplicationController
    before_filter :authenticate_user!  
  # GET /mybookpdfs
  # GET /mybookpdfs.xml
  def index
    @mybookpdfs = Mybookpdf.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mybookpdfs }
    end
  end

  # GET /mybookpdfs/1
  # GET /mybookpdfs/1.xml
  def show
    @mybookpdf = Mybookpdf.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mybookpdf }
    end
  end

  # GET /mybookpdfs/new
  # GET /mybookpdfs/new.xml
  def new
    @mybookpdf = Mybookpdf.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mybookpdf }
    end
  end

  # GET /mybookpdfs/1/edit
  def edit
    @mybookpdf = Mybookpdf.find(params[:id])
  end

  # POST /mybookpdfs
  # POST /mybookpdfs.xml
  def create
    @mybookpdf = Mybookpdf.new(params[:mybookpdf])

    respond_to do |format|
      if @mybookpdf.save
        flash[:notice] = 'Mybookpdf was successfully created.'
        format.html { redirect_to(@mybookpdf) }
        format.xml  { render :xml => @mybookpdf, :status => :created, :location => @mybookpdf }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mybookpdf.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /mybookpdfs/1
  # PUT /mybookpdfs/1.xml
  def update
    @mybookpdf = Mybookpdf.find(params[:id])

    respond_to do |format|
      if @mybookpdf.update_attributes(params[:mybookpdf])
        flash[:notice] = 'Mybookpdf was successfully updated.'
        format.html { redirect_to(@mybookpdf) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mybookpdf.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mybookpdfs/1
  # DELETE /mybookpdfs/1.xml
  def destroy
    @mybookpdf = Mybookpdf.find(params[:id])
    @mybookpdf.destroy

    respond_to do |format|
      format.html { redirect_to(mybookpdfs_url) }
      format.xml  { head :ok }
    end
  end
end
