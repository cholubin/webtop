# encoding: utf-8

class MytemplatesController < ApplicationController
  before_filter :authenticate_user!

  # GET /mytemplates
  # GET /mytemplates.xml
  def index

    #basic_photo 폴더링크가 없으면 생성한다.
    # user_path =  "#{RAILS_ROOT}" + "/public/user_files/#{current_user.userid}/images/basic_photo"
    # if not File.exist?(user_path)
    #   puts %x[ln -s "#{RAILS_ROOT}/public/basic_photo/" "#{RAILS_ROOT}/public/user_files/#{current_user.userid}/images/basic_photo"]
    # end
        
    @menu = "mytemplate"
    @board = "mytemplate"
    @section = "index"
    
    @category_name = params[:category_name]
    @subcategory_name = params[:subcategory_name]

    cate = params[:cate]
    folder = params[:folder]      

    if cate == "all" or cate == nil or cate == ""
      cate = "all"
    end
    if folder == "all" or folder == nil or folder == ""     
      folder = "all"
    end
          
    @categories = Category.all(:order => :priority)        

    if cate == "all" and folder == "all"
      @mytemplates = Mytemplate.all(:user_id => current_user.id, :order => [:created_at.desc]).search(params[:search], params[:page])                   
    elsif cate == "all" and folder != "all"
      @mytemplates = Mytemplate.all(:folder => Tempfolder.get(folder).name, :user_id => current_user.id, :order => [:created_at.desc]).search(params[:search], params[:page])                                   
    elsif cate != "all" and folder == "all"
      @mytemplates = Mytemplate.all(:category => cate, :user_id => current_user.id, :order => [:created_at.desc]).search(params[:search], params[:page])                                   
    elsif cate != "all" and folder != "all"
      @mytemplates = Mytemplate.all(:folder => Tempfolder.get(folder).name, :category => cate, :user_id => current_user.id, :order => [:created_at.desc]).search(params[:search], params[:page])                           
    end
    
    @tempfolders = Tempfolder.all(:user_id => current_user.id)
    render 'mytemplate'
  end
  
  def update_subcategories
      # updates subcategories based on (main)category selected
      
        categories = Category.first(:name => params[:category_id])
      subcategories = categories.subcategories

      # puts subcategories.inspect

      render :update do |page|
        page.replace_html 'subcategories', :partial => 'subcategories', :object => subcategories
      end
  end
  
  # GET /mytemplates/1
  # GET /mytemplates/1.xml
  def show
    @menu = "mytemplate"
    @board = "mytemplate"
    @section = "show"
    
    @categories = Category.all(:order => :priority)   
    @mytemplate = Mytemplate.get(params[:id])
    
    @category_name = @mytemplate.category
    @subcategory_name = @mytemplate.subcategory
    render 'mytemplate'    
  end

  # GET /mytemplates/new
  # GET /mytemplates/new.xml
  def new
    @mytemplate = Mytemplate.new
    @categories = Category.all(:order => :priority)    
    @subcategories = Subcategory.all(:order => :priority)
    
     render 'admin/mytemplates/new', :layout => false
  end

  # GET /mytemplates/1/edit
  def edit
    @menu = "mytemplate"
    @board = "mytemplate"
    @section = "edit"


    if Tempfolder.first(:user_id => current_user.id.to_s, :name => "기본") == nil
      @tempfolder = Tempfolder.new()
      @tempfolder.name = "기본"
      @tempfolder.user_id = current_user.id
      @tempfolder.save
    end
            
    @mytemplate = Mytemplate.get(params[:id])
    @tempfolders = Tempfolder.all(:user_id => current_user.id)    
    render 'mytemplate'
  end

  def publish
    if params[:press_mark] != nil and params[:press_mark] != ""
      press_mark = params[:press_mark]
    else
      press_mark = "NO"
    end
    
    @mytemplate = Mytemplate.first(:file_filename => params[:id] + ".mlayoutP.zip", :user_id => current_user.id)   
    erase_job_done_file(@mytemplate)       
    check_job_done_and_publish(@mytemplate, press_mark) 
    close_document(@mytemplate)  
    erase_job_done_file(@mytemplate)
    move_to_mypdf(@mytemplate)
    redirect_to :action => 'index'
  end

  def erase_job_done_file(mytemplate)         
    puts_message "erase_job_done_file start"
    
    path = mytemplate.path
  
    job_done = path + "/web/done.txt" 
    if File.exists?(job_done)
      FileUtils.remove_entry_secure(job_done)
      puts_message "job done file erased!"              
    end
    puts_message "erase_job_done_file end"      
  end

  def check_job_done_and_publish(mytemplate, press_mark)
    puts_message "check_job_done_and_publish start"      
    publish_mjob(mytemplate, press_mark) 
    set_pdf_path(mytemplate)    
    path = mytemplate.path
    # closing a doc right after generating pdf throws mlayout error
    # close_document(mytemplate)
    puts_message "check_job_done_and_publish end"      
  end
    
  def move_to_mypdf(mytemplate)
    puts_message "move_to_mypdf start!"

    mypdf = Mypdf.new
    mypdf.name = mytemplate.name
    mypdf.pdf_filename = mytemplate.file_filename.gsub(/.mlayoutP.zip/,'.pdf')
    mypdf.user_id = current_user.id
    
    
    #중복파일명 처리 
    while File.exist?(mypdf.basic_path + mypdf.pdf_filename) 
      mypdf.pdf_filename = mypdf.pdf_filename.gsub(/.pdf/,'') + "_1" + ".pdf"
    end
    
    source_path = @mytemplate.pdf_path
    destination_dir = mypdf.basic_path + mypdf.pdf_filename
    FileUtils.cp_r source_path, destination_dir
    
    #Thumbnail 생성 
    thumb_image_name = mypdf.pdf_filename.gsub(/.pdf/,'') + "_t" + ".jpg"
    preview_image_name = mypdf.pdf_filename.gsub(/.pdf/,'') + "_p" + ".jpg"
    
	  puts %x[#{RAILS_ROOT}"/lib/thumbup" #{mypdf.basic_path + mypdf.pdf_filename} #{mypdf.basic_path + preview_image_name} 0.5 #{mypdf.basic_path + thumb_image_name} 128]            	      
    
    mypdf.save
    # puts_message @mytemplate.pdf_path
    # puts_message @mytemplate.pdf    
    puts_message "move_to_mypdf end!"    
  end

  # POST /mytemplates
  # POST /mytemplates.xml
  def create
    @mytemplate = Mytemplate.new
    @mytemplate.user_id = current_user.id  
    @mytemplate.temp_id = params[:temp_id] 
    @mytemplate.save
    
    edit = params[:edit]

    copy_template(@mytemplate, @mytemplate.temp_id)    
    # if @mytemplate != nil && @mytemplate.save && @user.save        

    if @mytemplate.save              
      begin   
        # 템플릿 복사와 동시에 편집하는 경우
        if edit == "y"
          # @doc_name = @mytemplate.file_filename.gsub(/.zip/,'')
          @doc_name = @mytemplate.id.to_s + ".mlayoutP"       
          @userid = current_user.userid
          @menu = "mlayout"
          render '/cappuccino/show_cappuccino_ui', :layout => 'cappuccino', :popup=>true
          
                    
        # 템플릿 복사만 하는 경우
        else
          redirect_to :action => 'index'          
        end

      rescue
        flash[:error] = "Failed to process mlayout"
        render :action => 'index'
      end       
    else 
      flash[:error] = "Failed to create an mytemplate"
      render :action => 'new'
    end
  end
  
  def copyto_my_template
    @mytemplate = Mytemplate.new
    @mytemplate.user_id = current_user.id  
    @mytemplate.temp_id = params[:temp_id] 
    @mytemplate.save


    copy_template(@mytemplate, @mytemplate.temp_id)    
    # if @mytemplate != nil && @mytemplate.save && @user.save        
    @mytemplate
  
    render :update do |page|
      page.replace_html 'copy_template', :partial => 'copy_template'
    end  
  end  

  # PUT /mytemplates/1
  # PUT /mytemplates/1.xml
  def update
    @mytemplate = Mytemplate.get(params[:id])
    
    @mytemplate.name = params[:mytemplate][:name]
    @mytemplate.folder = params[:mytemplate][:folder]
    @mytemplate.description = params[:mytemplate][:description]
    
    respond_to do |format|
      if @mytemplate.save
        format.html { redirect_to mytemplates_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mytemplate.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mytemplates/1
  # DELETE /mytemplates/1.xml
  def destroy
    mytemplate = Mytemplate.get(params[:id])
    close_document(mytemplate)
    
    begin
      if mytemplate != nil
        if File.exist?(mytemplate.path.force_encoding('UTF8-MAC')) 
          FileUtils.remove_entry_secure mytemplate.path.force_encoding('UTF8-MAC') 
        end
      end
    rescue
      puts_message "Error! in progress of mytemplate file deletion."
    end
    
    mytemplate.destroy
    
    respond_to do |format|
      format.html { redirect_to(mytemplates_url) }
      format.xml  { head :ok }
    end
  end
  
  
    #::PRIVATE METHODS:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::    
  private  

    def check_done_txt(mytemplate) 
      path = mytemplate.path
      job_done = path+"/web/done.txt"
      if File.exists?(job_done)
        return true
      else
        return nil
      end
    end



    def check_jpg_and_process_thumbnail(mytemplate)
                            
       tpl = Temp.get(mytemplate.temp_id)  
       job_done = tpl.path + "/web/done.txt"             
       
       puts_message job_done
       loop do 
          break if File.exists?(job_done)
       end   
       process_index_thumbnail(mytemplate)

       # close_document(mytemplate)    
       # erase_job_done_file(mytemplate)   
    end 


    def find_user
      @user = current_user    
    end  

    def delete_template(mytemplate)   
      mytemplate.destroy  
       if mytemplate.path && File.exists?(mytemplate.path) 
          begin
            # FileUtils.remove_entry_secure @temp.path             
            FileUtils.remove_entry mytemplate.path             
          rescue
            flash[:notice] = "failed to delete mytemplate's template"
          end
        end
    end

    def reset_imgs(mytemplate)
      mytemplate.spread_imgs = nil 
      mytemplate.spread_imgs_url = nil  
      mytemplate.spread_mediums.each do |f|      
        FileUtils.remove_entry_secure(f) if File.exist?(f)     
      end   
      mytemplate.spread_mediums = nil
      mytemplate.spread_mediums_url = nil 
      mytemplate.spread_thumbs = nil
      mytemplate.spread_thumbs_url = nil   
    end

    def copy_template(mytemplate, temp_id)  

      path = "#{RAILS_ROOT}/public/user_files/" + current_user.userid + "/article_templates"
      
      # 복제될 템플릿 객체 원본
      @object_to_clone = Temp.get(temp_id) 
      
      # 복제된 템플릿 객체
      @cloned_object = mytemplate
      
      @cloned_object.name = @object_to_clone.name
      # @cloned_object.file_filename = @object_to_clone.file_filename
      @cloned_object.file_filename = @cloned_object.id.to_s

      @cloned_object.description = @object_to_clone.description
      @cloned_object.temp_id = temp_id 
      @cloned_object.user_id = current_user.id
      mytemplate_filename = @object_to_clone.file_filename.gsub(/.zip/,'')
      mytemplate_new_filename = @cloned_object.id.to_s + ".mlayoutP"

      
      temp_dir = path + "/" + mytemplate_filename      
      new_temp_dir = path + "/" + mytemplate_new_filename

      # while File.exist?(new_temp_dir) 
      #   mytemplate_new_filename = mytemplate_new_filename.gsub(/.mlayoutP/,'') + "_1" + ".mlayoutP"
      #   new_temp_dir = path + "/" + mytemplate_new_filename        
      # end

      @cloned_object.thumb_url = "/user_files/" + current_user.userid + "/article_templates/" +  mytemplate_new_filename + "/web/doc_thumb.jpg"         
      @cloned_object.preview_url = "/user_files/" + current_user.userid + "/article_templates/" + mytemplate_new_filename + "/web/doc_preview.jpg"             

      @cloned_object.category = @object_to_clone.category
      @cloned_object.subcategory = @object_to_clone.subcategory

      @cloned_object.file_filename = mytemplate_new_filename + ".zip"
      @cloned_object.path = "#{RAILS_ROOT}/public/user_files/" + current_user.userid + "/article_templates/" + mytemplate_new_filename
                  
      FileUtils.mkdir_p(File.dirname(new_temp_dir))   
            
      source_path = TEMP_PATH + mytemplate_filename
      
      if  RUBY_VERSION != "1.9.2"
        source_path = source_path.force_encoding('UTF8-MAC')
        new_temp_dir = new_temp_dir.force_encoding('UTF8-MAC')
      end
            
      FileUtils.cp_r source_path, new_temp_dir
      puts_message  "source_path: " + source_path
      puts_message  "new_temp_dir: " + new_temp_dir
      
      #--- delete template's mjob file     
      tmp = new_temp_dir + "/do_job.mjob"
      FileUtils.remove_entry_secure(tmp) if File.exist?(tmp)
      
      @cloned_object.save
      @object_to_clone.copy_cnt += 1
      @object_to_clone.save
      

    end     

    def generate_xml(mytemplate)   
       # erase_job_done_file(mytemplate)  
      xml_file = <<-EOF
      <xml>
        <title>#{mytemplate.title}</title>
        <subtitle>#{mytemplate.subtitle}</subtitle>
        <lead>#{mytemplate.lead}</lead>
        <author>#{mytemplate.author}</author>
        <body>#{mytemplate.body_html}</body>  
      </xml>
      EOF

      path = mytemplate.path
      write_2_file =  path + "/web/contents.xml"      
      File.open(write_2_file,'w') { |f| f.write xml_file }

      #================


      xml_file= <<-EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>WebRootPath</key>
        <string>#{M_ROOT}</string>
      	<key>Action</key>
      	<string>RefreshXML</string>
      	<key>DocPath</key>
      	<string>#{path}</string>   
        <key>ID</key>
       	<string>#{mytemplate.id}</string>    	
      </dict>
      </plist>

      EOF


       job_to_do = (path + "/refresh_xml_job.mJob")
       File.open(job_to_do,'w') { |f| f.write xml_file }    


       system("open #{job_to_do}")

      #================

    end 

    
    def close_document(mytemplate)  
      target_template = mytemplate
      path =  target_template.path

      close_xml= <<-EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>WebRootPath</key>
        <string>#{M_ROOT}</string>
      	<key>Action</key>
      	<string>CloseDocument</string>
      	<key>DocPath</key>
      	<string>#{path}</string>
      	<key>ID</key>
       	<string>#{mytemplate.id}</string>
      </dict>
      </plist>

      EOF

      close_job_file = path + "/close_job.mJob"
      
      if File.exist?(path)
        File.open(close_job_file,'w') { |f| f.write close_xml } 
        system "open #{close_job_file}"
      else
        puts_message "해당 템플릿은 이미 삭제된 상태입니다."
      end
    end


    def publish_mjob(mytemplate, press_mark)  
 
      puts_message "publish_mjob start press_mark added"      
      puts_message "press_mark:::" + press_mark
      # erase_job_done_file(mytemplate)   
      target_template = mytemplate
      goal = target_template.path    
      puts_message goal
#      goal = mypdf.basic_path    
      
      xml_file = <<-EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>PressMark</key>
        <string>#{press_mark}</string>
        <key>WebRootPath</key>
        <string>#{M_ROOT}</string>
      	<key>Action</key>
      	<string>SaveDocumentPDF</string>
      	<key>DocPath</key>
      	<string>#{goal}</string>   
      	<key>ID</key>
       	<string>#{mytemplate.temp_id}</string>    	
      </dict>
      </plist>

      EOF

      njob = target_template.path + "/publish_job.mJob" 
      File.open(njob,'w') { |f| f.write xml_file }    
      # process_index_thumbnail(target_template.path) 
      system "open #{njob}"
      

      goal = goal + "/web/document.pdf"

      job_done = target_template.path + "/web/done.txt" 


      puts_message "creating PDF file!!!"
      time_after_180_seconds = Time.now + 180.seconds     
      while Time.now < time_after_180_seconds
        break if File.exists?(job_done)
      end
      
      if !File.exists?(job_done)
        pid = `ps -c -eo pid,comm | grep MLayout`.to_s
        pid = pid.gsub(/MLayout 2/,'').gsub(' ', '')
        system "kill #{pid}"     
        puts_message "MLayout was killed!!!!! ============"
      else
        puts_message "There is job done file of PDF file making!"
      end
            
      set_pdf_path(mytemplate)
      puts_message "publish_mjob end"               
    end    

    def set_pdf_path(mytemplate)
      # mypdf = Mypdf.new
      # mypdf.user_id = current_user.id
      #        
      # puts_message mypdf.basic_path
      puts_message "set_pdf_path Start!"
      pdf = "#{RAILS_ROOT}" + "/public/user_files/" + current_user.userid + "/article_templates/" + "#{mytemplate.file_filename.gsub(/.zip/,'')}" +"/web/document.pdf"
      url = "#{HOSTING_URL}" + "/user_files/" + current_user.userid + "/article_templates/" + "#{mytemplate.file_filename.gsub(/.zip/,'')}" +"/web/document.pdf" 
      mytemplate.pdf = url 
      mytemplate.pdf_path = pdf
      if mytemplate.save
        puts_message "pdf_path saved!"
      else
        puts_message "pdf_path save failed!"
      end
      puts_message "set_pdf_path Finished!" 
    end


    #::IMAGE PROCESSING METHODS:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::      

    def process_index_thumbnail(mytemplate) 
      # tmpl = Temp.find_by_mytemplate_id(mytemplate.id) 
      # path = tmpl.path  

      base_dir = "#{RAILS_ROOT}" + "/public/user_files/" + current_user.userid + "/mytemplate_templates/" + "#{mytemplate.id}" +".mlayoutP/web/"
      previews = Dir.new(base_dir).entries.sort.delete_if{|x| !(x =~ /jpg$/)}.delete_if{|x| !(x =~ /spread_preview/)}   
      base_url = "#{HOSTING_URL}" + "/user_files/" + current_user.userid + "/mytemplate_templates/" + "#{mytemplate.id}" + ".mlayoutP/web/"
      index = 1   

      previews.each do |spread|  
        stamp = spread[/\_\d\d\d\d\.jpg/].gsub("_","").gsub(".jpg","")
        source_img = base_dir + spread
        preview_filename = spread
        medium_filename = ("spread_medium_000" + (index).to_s + "_" + stamp + ".jpg")
        thumb_filename = ("spread_thumb_000" + (index).to_s + "_" + stamp +".jpg")

        resize_and_write(source_img, base_dir + medium_filename, "medium")
        # resize_and_write(source_img, base_dir + thumb_filename , "thumb")

        mytemplate.spread_imgs << base_dir + preview_filename
        mytemplate.spread_imgs_url << base_url + preview_filename
        mytemplate.spread_mediums << base_dir + medium_filename
        mytemplate.spread_mediums_url << base_url + medium_filename
        mytemplate.spread_thumbs << base_dir + thumb_filename
        mytemplate.spread_thumbs_url << base_url + thumb_filename 
        index += 1             
      end 
      mytemplate.save 
      return true
    end   

    def resize_and_write(source_img, output, size)
      case size

      when "medium"
        processed_img = Miso::Image.new(source_img) 
        processed_img.crop(280, 124) 
        processed_img.fit(280, 124)
        processed_img.write(output)            
      when "thumb"
        # processed_img = Miso::Image.new(source_img) 
        # processed_img.crop(140, 62) 
        # processed_img.fit(140, 62)
        # processed_img.write(output)      
      else "error"
        # throw error
      end
    end  
end
