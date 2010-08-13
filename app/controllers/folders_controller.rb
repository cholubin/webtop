# encoding: utf-8
class FoldersController < ApplicationController
  before_filter :authenticate_user!    
  # GET /folders
  # GET /folders.xml
  def index
    @folders = Folder.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @folders }
    end
  end

  # GET /folders/1
  # GET /folders/1.xml
  def show
    @folder = Folder.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @folder }
    end
  end

  # GET /folders/new
  # GET /folders/new.xml
  def new
    @folder = Folder.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @folder }
    end
  end

  # GET /folders/1/edit
  def edit
    @folder = Folder.find(params[:id])
  end

  # POST /folders
  # POST /folders.xml
  def create
    @folder = Folder.new(params[:folder])

    respond_to do |format|
      if @folder.save
        flash[:notice] = 'Folder was successfully created.'
        format.html { redirect_to(@folder) }
        format.xml  { render :xml => @folder, :status => :created, :location => @folder }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @folder.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def create_folder

    if Folder.all(:name => params[:folder_name]).count < 1
      @folder = Folder.new()
      @folder.name = params[:folder_name]

      @folder.user_id = current_user.id

      basic_path = "#{RAILS_ROOT}" + "/public/user_files/#{current_user.userid}/images/"


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

    @folders = Folder.all(:user_id => current_user.id.to_s)
         
    render :update do |page|
      page.replace_html 'folder', :partial => 'folder', :object => @folders, :object => @already_done
      # page.visual_effect :Opacity, "folder", :from => 0.5, :to => 1.0, :duration => 2      
      page.replace_html 'folder_select', :partial => 'folder_select', :object => @folders     
    end
  end  

  def update_folder
        
    @folder = Folder.get(params[:folder_id].to_i)
    ori_folder_name = @folder.name
    ren_folder_name = params[:folder_name]    
    @folder.name = ren_folder_name
    
    basic_path = "#{RAILS_ROOT}" + "/public/user_files/#{current_user.userid}/images/"
    folder_path = basic_path + @folder.name

  	if @folder.save
  	  File.rename basic_path + ori_folder_name, basic_path  + ren_folder_name #original file
  	  
  	  @myimages = Myimage.all(:folder => ori_folder_name)

      @myimages.each do |m|
  	    m.folder = ren_folder_name        
  	    m.save        
      end

    end
    
    @folders = Folder.all(:user_id => current_user.id.to_s)
        
    render :update do |page|
      page.replace_html 'folder', :partial => 'folder', :object => @folders
      # page.visual_effect :Opacity, "folder", :from => 0.5, :to => 1.0, :duration => 2            
      page.replace_html 'folder_select', :partial => 'folder_select', :object => @folders     
    end    
  end    

  def destroy_folder

    folder_id = params[:folder_id]    
    @folder = Folder.get(folder_id)
    folder_name = @folder.name
    
    basic_path = "#{RAILS_ROOT}" + "/public/user_files/#{current_user.userid}/images/"
    folder_path = basic_path + @folder.name

    # # basic_photo 폴더는 삭제되지 않도록 한다.
    # if @folder.name != "basic_photo"
      if @folder.destroy
      
        #폴더 삭제 ========================================================
        if File.exist?(folder_path)
          FileUtils.rm_rf folder_path
        end
      
        #이미지 삭제 ========================================================      
    	  @myimages = Myimage.all(:folder => folder_name)
        @img_cnt = @myimages.count
        @myimages.each do |m|
    	    m.destroy        
        end      
      end
    # end
    
    @folders = Folder.all(:user_id => current_user.id.to_s)

    render :update do |page|
      page.replace_html 'folder', :partial => 'folder', :object => @folders, :object => @img_cnt
      # page.visual_effect :Opacity, "folder", :from => 0.5, :to => 1.0, :duration => 2            
      page.replace_html 'folder_select', :partial => 'folder_select', :object => @folders     
    end
  end
    
end

