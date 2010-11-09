# encoding: utf-8
class Admin::MyimagesController < ApplicationController
    layout 'admin_layout'
    before_filter :authenticate_admin!    
    
  # GET /myimages
  # GET /myimages.xml
  def index
      #확장자별 소팅
      gubun = params[:gb]
      ext = params[:ext]
      
      if gubun != "admin"
        @menu = "myimage"
        @board = "myimage"
        @section = "index"
        
        if ext == "all" or ext == nil or ext == ""
          @myimages = Myimage.all(:admin_id => nil, :order => [:created_at.desc]).search_user(params[:search], params[:page])   
          @total_count = Myimage.all(:admin_id => nil).search_user(params[:search], "").count
        else
          @myimages = Myimage.all(:admin_id => nil, :type => ext, :order => [:created_at.desc]).search_user(params[:search], params[:page])           
          @total_count = Myimage.all(:admin_id => nil, :type => ext).search_user(params[:search], "").count
        end
        
        render 'myimage'
        
      else
        @menu = "template"
        @board = "temp"
        @section = "admin_image"
        
        if ext == "all" or ext == nil or ext == ""
          @myimages = Myimage.all(:common => true, :order => [:created_at.desc]).search_user(params[:search], params[:page])   
          @total_count = Myimage.all(:common => true).search_user(params[:search], "").count   
        else
          @myimages = Myimage.all(:common => true, :type => ext, :order => [:created_at.desc]).search_user(params[:search], params[:page])           
          @total_count = Myimage.all(:common => true, :type => ext).search_user(params[:search], "").count
        end

        @exts = repository(:default).adapter.select('SELECT distinct type FROM myimages where common = \'t\'')
        
        render '/admin/temps/temp'
      end
      
  end

  def new
    @menu = "template"
    @board = "temp"
    @section = "image_new"
    
    @myimage = Myimage.new
      
    render '/admin/temps/temp'
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
    @menu = "template"
    @board = "temp"
    @section = "admin_image"
    
    @myimage = Myimage.new(params[:myimage])
    @myimage.admin_id = current_admin.id
    @myimage.user_id = current_admin.id
    @myimage.folder = "basic_photo"
    @myimage.common = true
    
    image_path = @myimage.image_path
    MyimageUploader.store_dir = @myimage.image_path
    
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
      end 

      ext_name = File.extname(@temp_filename)      
      file_name = @temp_filename.gsub(ext_name,'')
      
      #검색시 필터로 사용할 타입 설정
      @myimage.type = ext_name.gsub(".",'') 
       
      @myimage.image_filename = @temp_filename
      
      if ext_name == ".eps" or ext_name == ".pdf"
        @myimage.image_thumb_filename = file_name + ".png"
      else
        @myimage.image_thumb_filename = file_name + ".jpg"
      end
       # 중복파일명 처리 ===============================================================================

      @myimage.image_filename_encoded = @myimage.image_file.filename

      if params[:myimage][:name] == ""
        @myimage.name = file_name
      end

      
      if @myimage.save  
         # image filename renaming ======================================================================

         ext_name_up = File.extname(@myimage.image_filename_encoded)
         file_name_up = @myimage.image_filename_encoded.gsub(ext_name_up,'')
         
        if (file_name_up + ext_name_up)
          if  File.exist?(image_path + "/" + file_name_up + ext_name_up)
          	image_folder = "#{RAILS_ROOT}" + "/public/basic_photo"
        	  if ext_name_up == ".eps" or ext_name_up == ".pdf"
        	    puts %x[#{RAILS_ROOT}"/lib/thumbup" #{image_folder + "/" + @myimage.image_filename_encoded} #{image_folder + "/preview/" + file_name_up + ".png"} 0.5 #{image_folder + "/thumb/" + file_name_up + ".png"} 128]            	  
        	  else
        	    puts %x[#{RAILS_ROOT}"/lib/thumbup" #{image_folder + "/" + @myimage.image_filename_encoded} #{image_folder + "/preview/" + file_name_up + ".jpg"} 0.5 #{image_folder + "/thumb/" + file_name_up + ".jpg"} 128]            	  
        	  end
          end
        end      
         # image filename renaming ======================================================================
         @myimages = Myimage.all(:common => true, :order => [:created_at.desc]).search_user(params[:search], params[:page])   
         @total_count = @myimages.count
         @exts = repository(:default).adapter.select('SELECT distinct type FROM myimages where common = \'t\'')
         
         render '/admin/temps/temp', :object=>@myimages, :object=>@total_count
       else
         puts_message @myimage.errors.to_s
         render '/admin/temps/temp'
       end

    else
          flash[:notice] = '이미지는 반드시 선택하셔야 합니다.'      
          
          render '/admin/temps/temp'
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
  # GET /myimages/1
  # GET /myimages/1.xml
  def show
      @menu = "template"
      @board = "temp"
      @section = "image_show"
        
      @myimage = Myimage.get(params[:id])
      
      render '/admin/temps/temp'

  end

  # DELETE /myimages/1
  # DELETE /myimages/1.xml
  def destroy
    @myimage = Myimage.get(params[:id])
    ext_name_up = File.extname(@myimage.image_filename_encoded)
    filename = @myimage.image_filename_encoded.gsub(ext_name_up,"")
    
    if ext_name_up == ".eps" or ext_name_up == ".pdf"
      ext_name = ".png"
    else
      ext_name = ".jpg"
    end
    
    if  File.exist?(@myimage.image_admin_path + @myimage.image_filename_encoded)
  	  File.delete(@myimage.image_admin_path + @myimage.image_filename_encoded)         #original image file
      File.delete(@myimage.image_admin_path + "Thumb/" + filename + ext_name)   #thumbnail image file  	  
      File.delete(@myimage.image_admin_path + "Preview/" + filename + ext_name)   #thumbnail image file  	  
  	end
  	
    @myimage.destroy

    @menu = "template"
    @board = "temp"
    @section = "admin_image"
    
    @myimages = Myimage.all(:common => true, :order => [:created_at.desc])
    @total_count = @myimages.count
    @exts = repository(:default).adapter.select('SELECT distinct type FROM myimages where common = \'t\'')
    
    render '/admin/temps/temp'
  end
  
  # multiple deletion
  def deleteSelection 

    chk = params[:chk]

    if !chk.nil? 
      chk.each do |chk|
        @myimage = Myimage.get(chk[0].to_i)
        ext_name_up = File.extname(@myimage.image_filename_encoded)
        filename = @myimage.image_filename_encoded.gsub(ext_name_up,"")

        if ext_name_up == ".eps" or ext_name_up == ".pdf"
          ext_name = ".png"
        else
          ext_name = ".jpg"
        end
        
        if  File.exist?(@myimage.image_admin_path + @myimage.image_filename_encoded)
      	  File.delete(@myimage.image_admin_path + @myimage.image_filename_encoded)         #original image file
          File.delete(@myimage.image_admin_path + "Thumb/" + filename + ext_name)   #thumbnail image file  	  
          File.delete(@myimage.image_admin_path + "Preview/" + filename + ext_name)   #thumbnail image file  	  
      	end
        @myimage.destroy    
      end
    else
        flash[:notice] = '삭제할 글을 선택하지 않으셨습니다!'    
    end
      
    @menu = "template"
    @board = "temp"
    @section = "admin_image"

    @myimages = Myimage.all(:common => true, :order => [:created_at.desc])
    @total_count = @myimages.count
    @exts = repository(:default).adapter.select('SELECT distinct type FROM myimages where common = \'t\'')
        
    render '/admin/temps/temp'  
   end
     
end
