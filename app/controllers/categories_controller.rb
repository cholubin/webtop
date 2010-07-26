# encoding: utf-8

class CategoriesController < ApplicationController
   before_filter :authenticate_admin! , :only => [:create, :update, :destroy]        
  # GET /admin_categories
  # GET /admin_categories.xml
  def index
    @menu = "category"
    @board = "category"
    @section = "index"
      
    @categories = Category.all(:order => [ :priority.asc ])

     render 'admin/categories/category', :layout => false
  end
  


  # GET /admin_categories/1
  # GET /admin_categories/1.xml
  def show
    @menu = "category"
    @board = "category"
    @section = "show"
        
    @category = Category.get(params[:id])
    @subcategories = @category.subcategories.all(:order => [ :priority.asc ])
    
     render 'admin/categories/category', :layout => false
  end

  # GET /admin_categories/new
  # GET /admin_categories/new.xml
  def new
    @menu = "category"
    @board = "category"
    @section = "new"
      
    @category = Category.new
    @select_main_category = Category.all(:order => [ :priority.asc ])  

     render 'admin/categories/category'
  end

  # GET /admin_categories/1/edit
  def edit
    @category = Category.get(params[:id])
  end

  # POST /admin_categories
  # POST /admin_categories.xml
  def create
    if params[:categories][:name] != "" and params[:categories][:sub_name] == ""
      @category = Category.new
      @category.name = params[:categories][:name]
      @category.priority = params[:categories][:priority].to_i
      
      if @category.save
        flash[:notice] = 'Main category was successfully created.'
        redirect_to :action => 'index'
      else
       render :action => 'new'        
      end

    elsif params[:categories][:name] == "" and params[:categories][:sub_name] != ""
      @category = Category.get(params[:categories][:main_category].to_i)
      @sub_category = @category.subcategories.new
      @sub_category.name = params[:categories][:sub_name]
      @sub_category.priority = params[:categories][:sub_priority].to_i

      if @sub_category.save
        flash[:notice] = 'Sub category was successfully created.'
        redirect_to :action => 'index'
      else
       render :action => 'new'        
      end

    end
  
    

  end

  # PUT /admin_categories/1
  # PUT /admin_categories/1.xml
  def update
    @category = Category.get(params[:id])

    respond_to do |format|
      if @category.update_attributes(params[:category])
        flash[:notice] = 'Category was successfully updated.'
        format.html { redirect_to(@category) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

end
