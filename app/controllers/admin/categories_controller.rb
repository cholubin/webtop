# encoding: utf-8

class Admin::CategoriesController < ApplicationController
  before_filter :authenticate_admin!      
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
    
    @menu = "category"
    @board = "category"
    @section = "edit"
        
    @category = Category.get(params[:id])
    
    render 'category'
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
    @menu = "category"
    @board = "category"
    @section = "edit"
    
    @category = Category.get(params[:id])
    
    @category.name = params[:category][:name]
    @category.priority = params[:category][:priority].to_i
        
      if @category.save
        redirect_to (admin_category_url)
      else
        render 'category'
      end

  end

  # # DELETE /admin_categories/1
  # # DELETE /admin_categories/1.xml
  # def destroy
  #   puts "==============================="
  #   @category = Category.get(params[:id])
  #   @subcategoris = Subcategory.all(:category_id => @category.id)
  #   
  # 
  #   if @subcategoris.destroy
  #     @category.destroy
  #     redirect_to admin_categories_url      
  #   else
  #     puts_message "Error occured during deleting subcategories"
  #     redirect_to admin_categories_url      
  #   end
  # end
  # 
  # def destroy_sub
  #   @categories = Category.all
  #   @subcategory = @categories.subcategories.get(params[:id].to_i)
  #   
  #   if @subcategory.destroy
  #     redirect_to admin_categories_url      
  #   else
  #     puts_message "Error occured during deleting subcategories"
  #     redirect_to admin_categories_url      
  #   end
  # end  

  def category_order_update
    category_id = params[:category_id].split(',')
    
    if !category_id.nil? 
      i = 1
      category_id.each do |c|
        temp = c.split('_')
        category = Category.get(temp[1].to_i)
        category.priority = i
        category.save
        i += 1
      end
    end

  puts_message "category sorting has finished!"
  render :nothing => true
  end

  def subcategory_order_update
    subcategory_id = params[:subcategory_id].split(',')
    @category = Category.get(params[:category_id].to_i)
    
    if !subcategory_id.nil? 
      i = 1
      subcategory_id.each do |s|
        temp = s.split('_')
        subcategory = Subcategory.get(temp[1].to_i)
        subcategory.priority = i
        subcategory.save
        
        i += 1
      end
    end

    puts_message "subcategory sorting has finished!"
  render :nothing => true
  end

  def add_category
    category_name = params[:category_name]
    
    categories = Category.all(:order => [:priority])

    i = 2
    categories.each do |c|
      c.priority = i
      c.save
      i += 1
    end
    
    category = Category.new()
    category.name = category_name
    category.priority = 1
    category.save
    
    @category = category
    
    render :update do |page|
      page.replace_html 'created_category', :partial => 'created_category', :object => @category
    end
  end
  
  def add_subcategory
    category_id = params[:category_id]
    subcategory_name = params[:subcategory_name]
    
    @category = Category.get(category_id.to_i)
    @subcategory = @category.subcategories.new

    if @category.subcategories.first(:order => [:priority.desc]).nil?
      max_order = 0
    else
      max_order =  @category.subcategories.first(:order => [:priority.desc]).priority
    end
    
    puts_message max_order.to_s
    
    @subcategory.priority = max_order + 1
    @subcategory.name = subcategory_name
    
    if @subcategory.save
      puts_message "adding subcategory has finished!"
    else
      puts_message "erorr occrued!"
    end

    @category_id = category_id
    render :update do |page|
      page.replace_html 'created_subcategory', :partial => 'created_subcategory', :object => @subcategory, :object => @category_id
    end

  end

  def delete_category
    temp_category_name = params[:category_id].split('_')
    puts_message params[:category_id]
    
    category_selector = temp_category_name[0]
    id = temp_category_name[1]
    
    if category_selector == "cate-del"
      #카테고리 삭제의
      category_id = id.to_i
      @category = Category.get(id.to_i)
      @subcategories = Subcategory.all(:category_id => @category.id)
    
    
      if @subcategories.destroy
        puts_message "서브카테고리들 삭제 완료!"
        if @category.destroy
          puts_message "카테고리 삭제 완료!"
        end
      end
    else
    #서브카테고리의 삭제 
    @subcategory = Subcategory.get(id.to_i)
      if @subcategory.destroy
        puts_message "서브카테고리 삭제 완료!"
      end
    end
    
    render :nothing => true
  end
  
  def update_category
    temp_category_id = params[:category_id].split('_')
    category_name = params[:category_name]
    category_selector = temp_category_id[0]
    category_id = temp_category_id[1]
    
    if category_selector == "cate-edit"
      @category = Category.get(category_id.to_i)
      @category.name = category_name
      if @category.save
        puts_message "카테고리 업데이트 완료!"
      end
    else
      @subcategory = Subcategory.get(category_id.to_i)
      @subcategory.name = category_name
      if @subcategory.save
        puts_message "서브카테고리 업데이트 완료!"
      end
    end
    render :nothing => true
  end
  
end
