# encoding: utf-8
class MybooksController < ApplicationController
  before_filter :authenticate_user!    
  # GET /folders
  # GET /folmybookfolderders.xml
  def index
    @folders = Mybook.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @folders }
    end
  end

  # GET /mybookfolders/1
  # GET /mybookfolders/1.xml
  def show
    @folder = Mybook.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @folder }
    end
  end

  # GET /mybookfolders/new
  # GET /mybookfolders/new.xml
  def new
    @folder = Mybook.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @folder }
    end
  end

  # GET /mybookfolders/1/edit
  def edit
    @folder = Mybook.find(params[:id])
  end

  # POST /mybookfolders
  # POST /mybookfolders.xml
  def create
    @folder = Mybook.new(params[:mybookfolder])

    respond_to do |format|
      if @folder.save
        flash[:notice] = 'Mybook was successfully created.'
        format.html { redirect_to(@folder) }
        format.xml  { render :xml => @folder, :status => :created, :location => @folder }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @folder.errors, :status => :unprocessable_entity }
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
      page.replace_html 'folder', :partial => 'folder', :object => @folders, :object => @already_done
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
      page.replace_html 'folder', :partial => 'folder', :object => @folders
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
      page.replace_html 'folder', :partial => 'folder', :object => @folders, :object => @pdf_cnt
      # page.visual_effect :Opacity, "folder", :from => 0.5, :to => 1.0, :duration => 2            
      page.replace_html 'folder_select', :partial => 'folder_select', :object => @folders     
    end
  end
    
end

