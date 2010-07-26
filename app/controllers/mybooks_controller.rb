# encoding: utf-8
class MybooksController < ApplicationController
  before_filter :authenticate_user!  
  # GET /mybooks
  # GET /mybooks.xml
  def index
    book_id = params[:book_id]

    @mybooks = Mybook.all(:user_id => current_user.id, :order => [:order])
    if book_id == nil
      if @mybooks.count > 0
        book_id = Mybook.first(:user_id => current_user.id, :order => [:order]).id.to_s
      end
    end
    @mybookfolder = Mybookfolder.get(book_id.to_i)
    @mybookpdfs = Mybookpdf.all(:mybook_id => book_id.to_i, :order => [:order])
    puts_message @mybookpdfs.count.to_s
    @menu = "mytemplate"
    @board = "mybook"
    @section = "index"
    
    @folders = Mybook.all(:user_id => current_user.id)
    
    render 'mybook'
  end

  # GET /mybooks/1
  # GET /mybooks/1.xml
  def show
    @mybook = Mybook.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mybook }
    end
  end

  # GET /mybooks/new
  # GET /mybooks/new.xml
  def new
    @mybook = Mybook.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mybook }
    end
  end

  # GET /mybooks/1/edit
  def edit
    @mybook = Mybook.find(params[:id])
  end

  # POST /mybooks
  # POST /mybooks.xml
  def create
    @mybook = Mybook.new(params[:mybook])

    respond_to do |format|
      if @mybook.save
        flash[:notice] = 'Mybook was successfully created.'
        format.html { redirect_to(@mybook) }
        format.xml  { render :xml => @mybook, :status => :created, :location => @mybook }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mybook.errors, :status => :unprocessable_entity }
      end
    end
  end

  def create_folder

    if Mybook.all(:folder_name => params[:folder_name]).count < 1
      @folder = Mybook.new()
      @folder.name = params[:folder_name]
      @folder.folder_name = sanitize_filename(params[:folder_name])

      @folder.user_id = current_user.id

      basic_path = "#{RAILS_ROOT}" + "/public/user_files/#{current_user.userid}/mybook/"


      dir = basic_path + @folder.name

      if !File.exist?(dir)
       FileUtils.mkdir_p dir if not File.exist?(dir)
       FileUtils.chmod 0777, dir

       @folder.save
      end
    else
      puts_message "이미 생성된 폴더명입니다!"
      @already_done = true
    end

    @folders = Mybook.all(:user_id => current_user.id.to_s)
         
    render :update do |page|
      page.replace_html 'folder', :partial => 'mybookfolder', :object => @folders, :object => @already_done
      # page.visual_effect :Opacity, "folder", :from => 0.5, :to => 1.0, :duration => 2      
      page.replace_html 'folder_select', :partial => 'folder_select', :object => @folders     
    end
  end  

  def update_folder
        
    @folder = Mybook.get(params[:folder_id].to_i)
    ori_name = @folder.name
    ori_folder_name = @folder.folder_name
    ren_name = params[:folder_name]
    ren_folder_name = sanitize_filename(params[:folder_name])
    @folder.folder_name = ren_folder_name
    @folder.name = ren_name
    
    basic_path = "#{RAILS_ROOT}" + "/public/user_files/#{current_user.userid}/mybook/"
    folder_path = basic_path + @folder.name

  	if @folder.save
  	  File.rename basic_path + ori_folder_name, basic_path  + ren_folder_name #original file
  	  
  	  @mybookpdfs = Mybookpdf.all(:folder_name => ori_folder_name)

      @myimages.each do |m|
  	    m.folder_name = ren_folder_name        
  	    m.save        
      end

    end
    
    @folders = Mybook.all(:user_id => current_user.id.to_s)
        
    render :update do |page|
      page.replace_html 'folder', :partial => 'mybookfolder', :object => @folders
      # page.visual_effect :Opacity, "folder", :from => 0.5, :to => 1.0, :duration => 2            
      page.replace_html 'folder_select', :partial => 'folder_select', :object => @folders     
    end    
  end    

  def destroy_folder

    folder_id = params[:folder_id]    
    @folder = Mybook.get(folder_id)
    folder_name = @folder.folder_name
    
    basic_path = "#{RAILS_ROOT}" + "/public/user_files/#{current_user.userid}/mybook/"
    folder_path = basic_path + folder_name

    if @folder.destroy
      
      #폴더 삭제 ========================================================
      if File.exist?(folder_path)
        FileUtils.rm_rf folder_path
      end
      
      #이미지 삭제 ========================================================      
  	  @mybookpdfs = Mybookpdf.all(:folder_name => folder_name)
      @pdf_cnt = @mybookpdfs.count
      @mybookpdfs.each do |m|
  	    m.destroy        
      end      
    end
    
    @folders = Mybook.all(:user_id => current_user.id.to_s)

    render :update do |page|
      page.replace_html 'folder', :partial => 'mybookfolder', :object => @folders, :object => @pdf_cnt
      # page.visual_effect :Opacity, "folder", :from => 0.5, :to => 1.0, :duration => 2            
      page.replace_html 'folder_select', :partial => 'folder_select', :object => @folders     
    end
  end
  
  def save_order

    mybook_id = params[:mybook_id].to_i
    chk = params[:pdf_id].split(',')

    if !chk.nil? 
      i = 1
      chk.each do |c|
        mybookpdf = Mybookpdf.get(c.to_i)
        puts_message mybookpdf.order.to_s
        mybookpdf.order = i
        mybookpdf.save
        
        i += 1
      end
    else
      puts "선택을 해야쥐!!"
    end

    @mybookpdfs = Mybookpdf.all(:mybook_id => mybook_id, :order => [:order])
    @mode = "update_sort"

    render :update do |page|
      # page.replace_html 'folder', :partial => 'mybookfolder', :object => @folders, :object => @pdf_cnt
      page.replace_html 'dp_sub', :partial => 'dp_sub', :object => @mybookpdfs, :object => @mode
    end
    

  end

  def book_order_update

    book_id = params[:book_id].split(',')

    if !book_id.nil? 
      i = 1
      book_id.each do |c|
        mybook = Mybook.get(c.to_i)
        mybook.order = i
        mybook.save
        
        i += 1
      end
    end

    @mybooks = Mybook.all(:order => [:order], :user_id => current_user.id)
    
    render :nothing => true 
    # render :update do |page|
    #   page.replace_html 'sortables_book', :partial => 'sortables_book', :object => @mybooks
    # end
    
  end
  
  
  def deleteSelection  
    mybook_id = params[:mybook_id].to_i
    chk = params[:pdf_id].split(',')

    if !chk.nil? 
      chk.each do |c|
        mybookpdf = Mybookpdf.get(c.to_i)
        
        # delete pdf,thumb,preview files
        basic_path = mybookpdf.basic_path
        pdf_path = basic_path + mybookpdf.name + ".pdf"
        thumb_path = basic_path + mybookpdf.name + "_t.jpg"
        preview_path = basic_path + mybookpdf.name + "_p.jpg"
        
        if File.exist?(pdf_path); File.delete(pdf_path); end
        if File.exist?(thumb_path); File.delete(thumb_path); end
        if File.exist?(preview_path); File.delete(preview_path); end
        
        # delete db
        mybookpdf.destroy
      end
    end

    # 순서 재 저장
    if !chk.nil? 
      i = 1
      mybookpdfs = Mybookpdf.all(:mybook_id => mybook_id, :order => [:order])
      mybookpdfs.each do |pdf|
        pdf.order = i
        pdf.save
        i += 1
      end
    end
        

    @mybookpdfs = Mybookpdf.all(:mybook_id => mybook_id, :order => [:order])
    @chk_cnt = chk.count
    @mode = "delete"
    
    render :update do |page|
      page.replace_html 'dp_sub', :partial => 'dp_sub', :object => @mybookpdfs, :object => @chk_cnt, :object => @mode
    end    
  end
  
end
