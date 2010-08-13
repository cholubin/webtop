# encoding: utf-8

class MyimagesController < ApplicationController
    before_filter :authenticate_user!  
  # GET /myimages
  # GET /myimages.xml
  def index
    
    #basic_photo 폴더링크가 없으면 생성한다.
    user_path =  "#{RAILS_ROOT}" + "/public/user_files/#{current_user.userid}/images/basic_photo"
    if not File.exist?(user_path)
      puts %x[ln -s "#{RAILS_ROOT}/public/basic_photo/" "#{RAILS_ROOT}/public/user_files/#{current_user.userid}/images/basic_photo"]
    end
    
    #확장자별 소팅
    ext = params[:ext]
    folder = params[:folder]
    
    @menu = "mytemplate"
    @board = "myimage"
    @section = "index"
  
    if ext == "all" or ext == nil or ext == ""
      ext = "all"
    end
    if folder == "all" or folder == nil or folder == ""     
      folder = "all"
    end
        
    if ext == "all" and folder == "all"
      @myimages = Myimage.all(:user_id => current_user.id, :order => [:created_at.desc]).search_user(params[:search], params[:page])                   
    elsif ext == "all" and folder != "all"
      @myimages = Myimage.all(:folder => Folder.get(folder).name, :user_id => current_user.id, :order => [:created_at.desc]).search_user(params[:search], params[:page])                                   
    elsif ext != "all" and folder == "all"
      @myimages = Myimage.all(:type => ext, :user_id => current_user.id, :order => [:created_at.desc]).search_user(params[:search], params[:page])                                   
    elsif ext != "all" and folder != "all"
      @myimages = Myimage.all(:folder => Folder.get(folder).name, :type => ext, :user_id => current_user.id, :order => [:created_at.desc]).search_user(params[:search], params[:page])                           
    end
    
    @folders = Folder.all(:user_id => current_user.id)

    render 'myimage'
    
    
  end

  # GET /myimages/1
  # GET /myimages/1.xml
  def show
    if signed_in?
      @menu = "mytemplate"      
      @board = "myimage"
      @section = "show"
        
      @myimage = Myimage.get(params[:id])
      
      if @myimage.user_id == current_user.id
        render 'myimage'
      else
        redirect_to '/'
      end

    else
      redirect_to '/login'
    end
  end

  # GET /myimages/new
  # GET /myimages/new.xml
  def new
    @menu = "mytemplate"    
    @board = "myimage"
    @section = "new"
    
    @myimage = Myimage.new
  
    
    if Folder.first(:user_id => current_user.id.to_s, :name => "photo") == nil
      @folder = Folder.new()
      @folder.name = "photo"
      @folder.user_id = current_user.id
      @folder.save
    end

    @folders = Folder.all(:user_id => current_user.id)
      
    render 'myimage'
  end

  # GET /myimages/1/edit
  def edit
    @myimage = Myimage.get(params[:id])

    @menu = "mytemplate"    
    @board = "myimage"
    @section = "edit"

    @folders = Folder.all(:user_id => current_user.id)
        
    render 'myimage'    
  end

  # POST /myimages
  # POST /myimages.xml
  def create
    @menu = "mytemplate"    
    @board = "myimage"
    @section = "new"
    
    @myimage = Myimage.new(params[:myimage])
    @myimage.user_id = current_user.id
    
    image_path = @myimage.image_path

    # 이미지 업로드 처리 ===============================================================================
    if params[:myimage][:image_file] != nil

      @myimage.image_file = params[:myimage][:image_file]      
      @temp_filename = sanitize_filename(params[:myimage][:image_file].original_filename)


      # 중복파일명 처리 ===============================================================================
      while File.exist?(image_path + "/" + @temp_filename) 
        ext_name = File.extname(@temp_filename)
        file_name = @temp_filename.gsub(ext_name,'')

        @temp_filename = file_name + "_1" + ext_name
        @myimage.image_filename = @temp_filename
        
        puts image_path + "/" + @temp_filename
      end 

      ext_name = File.extname(@temp_filename)      
      file_name = @temp_filename.gsub(ext_name,'')
      #검색시 필터로 사용할 타입 설정
      @myimage.type = ext_name.gsub(".",'') 
       
      @myimage.image_filename = @temp_filename
      @myimage.image_thumb_filename = file_name + ".jpg"
       # 중복파일명 처리 ===============================================================================

      @myimage.image_filename_encoded = @myimage.image_file.filename

      if params[:myimage][:name] == ""
        @myimage.name = file_name
      end

      if params[:myimage][:folder] == ""
        @myimage.folder = "photo"
      else
        @myimage.folder = params[:myimage][:folder]
      end
      puts_message @myimage.folder
      
      if @myimage.save  
         # image filename renaming ======================================================================

         ext_name_up = File.extname(@myimage.image_filename_encoded)
         file_name_up = @myimage.image_filename_encoded.gsub(ext_name_up,'')
         
         
        if (file_name_up + ext_name_up)
          if  File.exist?(image_path + "/" + file_name_up + ext_name_up)
            if params[:myimage][:folder] == "photo"
          	  File.rename image_path + "/" + @myimage.image_filename_encoded, image_path  + "/" + file_name + ext_name #original file
          	  puts %x[#{RAILS_ROOT}"/lib/thumbup" #{image_path + "/" + @myimage.image_filename} #{image_path + "/preview/" + file_name + ".jpg"} 0.5 #{image_path + "/thumb/" + file_name + ".jpg"} 128]            	  
          	else
          	  image_folder = @myimage.image_folder(params[:myimage][:folder])
          	  File.rename image_path + "/" + @myimage.image_filename_encoded, image_folder  + "/" + file_name + ext_name #original file
          	  puts %x[#{RAILS_ROOT}"/lib/thumbup" #{image_folder + "/" + @myimage.image_filename} #{image_folder + "/preview/" + file_name + ".jpg"} 0.5 #{image_folder + "/thumb/" + file_name + ".jpg"} 128]            	  
          	end
          end
        end      
         # image filename renaming ======================================================================
         redirect_to myimages_path
       else
         render 'myimage'
       end

    else
          flash[:notice] = '이미지는 반드시 선택하셔야 합니다.'      
          
          render 'myimage'
    end
      
      # MyimageUploader.store_dir = @myimage.image_path

  end

  # PUT /myimages/1
  # PUT /myimages/1.xml
  def update
    
    #레이아웃 관련 변수 
    @menu = "mytemplate"    
    @board = "myimage"
    @section = "edit"

    #페이징 관련 변수 
    search = params[:search]
    ext = params[:ext]

    #모델관련 변수 
    @myimage = Myimage.get(params[:id])
    @myimage.name = params[:myimage][:name]
    @myimage.description = params[:myimage][:description]
    new_folder_name = params[:myimage][:folder]
    old_folder_name = @myimage.folder
    @myimage.folder = new_folder_name
    
    image_path_basic = @myimage.image_path                          # 기본 이미지폴더 (photo)
    image_path_new_folder = @myimage.image_folder(new_folder_name)  # 변경될 폴더 
    image_path_old_folder = @myimage.image_folder(old_folder_name)  # 기존 폴더     
    
          
    ext_name = File.extname(@myimage.image_filename)
    file_name = @myimage.image_filename.gsub(ext_name,'')

    #파일명의 확장자로 판단하여 타입결정
    @myimage.type = ext_name.gsub('.','')

    #이미지를 변경하는 경우 
    if params[:myimage][:image_file] != nil
      #먼저 기존에 업로드된 이미지를 삭제한다.
      if !@myimage.image_path.nil? && !@myimage.image_filename.nil?
        if  File.exist?(image_path_old_folder + "/" + @myimage.image_filename)
          #오리지날 파일 삭제
      	  File.delete(image_path_old_folder + "/" + @myimage.image_filename)         #original image file      
      	  # 썸네일 삭제
      	  if File.exist?(image_path_old_folder + "/thumb/" + @myimage.image_filename)
      	    File.delete(image_path_old_folder + "/thumb/" + @myimage.image_filename)         #original image file
      	  end
      	  # 프리뷰 삭제
      	  if File.exist?(image_path_old_folder + "/preview/" + @myimage.image_filename)
            File.delete(image_path_old_folder + "/preview/" + @myimage.image_filename)   #thumbnail image file  	  
          end
      	end
    	end
    	
    	#새로운 이미지파일을 업로드 한다.
      @myimage.image_file = params[:myimage][:image_file]      
      @temp_filename = sanitize_filename(params[:myimage][:image_file].original_filename)

      # 중복파일명 처리 ===============================================================================
      # 중복체크는 기본폴더(photo)에서 한 후 목표 폴더로 이동처리 한다. (캐리어웨이브 제약조건 때문.)
      while File.exist?(image_path_basic + "/" + @temp_filename) 
        @temp_filename = @temp_filename.gsub(File.extname(@temp_filename),"") + "_1" + File.extname(@temp_filename)
        @myimage.image_filename = @temp_filename
      end 
      @myimage.image_filename = @temp_filename
      @myimage.image_thumb_filename = @temp_filename
      # 중복파일명 처리 ===============================================================================

      @myimage.image_filename_encoded = @myimage.image_file.filename    	
    end

    if @myimage.save
      if @temp_filename != nil
        file_name = @myimage.image_filename.gsub(File.extname(@temp_filename),"")
      else
        file_name = @myimage.image_filename.gsub(ext_name,"")        
      end

      #파일을 새롭게 업로드하는 경우 
      if params[:myimage][:image_file] != nil
    	  File.rename image_path_basic + "/" + @myimage.image_filename_encoded, image_path_new_folder  + "/" + @myimage.image_filename #original file
    	  #썸네일생성 
    	  puts %x[#{RAILS_ROOT}"/lib/thumbup" #{image_path_new_folder + "/" + @myimage.image_filename} #{image_path_new_folder + "/preview/" + file_name + ".jpg"} 0.5 #{image_path_new_folder + "/thumb/" + file_name + ".jpg"} 128]            	  

      #폴더만 변경하는 경우 
      else
        puts "====================================================================="
        puts image_path_old_folder + "/" + @myimage.image_filename
        puts "====================================================================="        
    	  File.rename image_path_old_folder + "/" + @myimage.image_filename, image_path_new_folder  + "/" + @myimage.image_filename #original file
    	  File.rename image_path_old_folder + "/Preview/" + file_name + ".jpg", image_path_new_folder  + "/Preview/" + file_name + ".jpg" #original file
    	  File.rename image_path_old_folder + "/Thumb/" + file_name + ".jpg", image_path_new_folder  + "/Thumb/" + file_name + ".jpg" #original file
      end
      
      redirect_to '/myimages?search='+search+'&ext='+ext
    else
      render 'myimage'
    end


  end

  # DELETE /myimages/1
  # DELETE /myimages/1.xml
  def destroy
    @myimage = Myimage.get(params[:id])
    
    image_path = @myimage.image_folder(@myimage.folder)
    
    if !image_path.nil? && !@myimage.image_filename.nil?
      if  File.exist?(image_path + "/" + @myimage.image_filename)
      
        #오리지날 파일 삭제
    	  File.delete(image_path + "/" + @myimage.image_filename)         #original image file      
  	  
    	  # 썸네일 삭제
    	  if File.exist?(image_path + "/thumb/" + @myimage.image_filename)
    	    File.delete(image_path + "/thumb/" + @myimage.image_filename)         #original image file
    	  end
    	  # 프리뷰 삭제
    	  if File.exist?(image_path + "/preview/" + @myimage.image_filename)
          File.delete(image_path + "/preview/" + @myimage.image_filename)   #thumbnail image file  	  
        end
    	end
  	end
    @myimage.destroy

    respond_to do |format|
      format.html { redirect_to(myimages_url) }
      format.xml  { head :ok }
    end
  end
end
