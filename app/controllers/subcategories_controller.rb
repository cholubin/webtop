# encoding: utf-8

class SubcategoriesController < ApplicationController
  # GET /subcategories
  # GET /subcategories.xml
  def index
    # @category = Category.all
    @subcategories = Category.all(:order => [ :priority.asc ]).subcategories.all
         
    # @subcategories = Subcategory.all

     render 'admin/subcategories/index', :layout => false
  end

  # GET /subcategories/1
  # GET /subcategories/1.xml
  def show
    @subcategory = Subcategory.get(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @subcategory }
    end
  end

  # GET /subcategories/new
  # GET /subcategories/new.xml
  def new
    @category = Category.new
    @subcategory = @category.subcategories.new
    @select_main_category = Category.all(:order => [ :priority.asc ])  
  
    render 'admin/subcategories/new', :layout => false
  end

  # GET /subcategories/1/edit
  def edit
    @subcategory = Category.all.subcategories.get(params[:id])
    @select_main_category = Category.all(:order => [ :priority.asc ])  
    
   render 'admin/subcategories/edit', :layout => false
  end

  # POST /subcategories
  # POST /subcategories.xml
  def create
    @category = Category.get(params[:subcategories][:main_category].to_i)
    @subcategory = @category.subcategories.new
    
    @subcategory.name = params[:subcategories][:name]
    @subcategory.priority = params[:subcategories][:priority].to_i

    if @subcategory.save
      flash[:notice] = 'Sub category was successfully created.'
        redirect_to :action => 'index'
    else
      render 'admin/subcategories/new', :layout => false
    end
  end

  # PUT /subcategories/1
  # PUT /subcategories/1.xml
  def update

    @category = Category.all
    @subcategory = @category.subcategories.get(params[:id])
    @subcategory.category_id = params[:subcategories][:main_category].to_i
    @subcategory.name = params[:subcategory][:name]
    @subcategory.priority = params[:subcategory][:priority].to_i
    
    if @subcategory.save
      flash[:notice] = 'Sub category was successfully updated.'
        redirect_to :action => 'index'
    else
      render 'admin/subcategories/new', :layout => false
    end
  end

  # DELETE /subcategories/1
  # DELETE /subcategories/1.xml
  def destroy
    @subcategory = Category.subcategories.get(params[:id])
    @subcategory.destroy
    
    redirect_to admin_category_url
  end
end
