# encoding: utf-8
class MypdfsController < ApplicationController
    before_filter :authenticate_user!  
      
    def index
      @mypdfs = Mypdf.all(:user_id => current_user.id, :order => [:created_at.desc]).search(params[:search], params[:page])   

      @menu = "mytemplate"
      @board = "mypdf"
      @section = "index"
      
      @mybooks = Mybook.all(:user_id => current_user.id.to_i)
      render 'mypdf' 
    end

    # GET /mypdfs/1
    # GET /mypdfs/1.xml
    def show
      @mypdf = Mypdf.get(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @mypdf }
      end
    end

    # GET /mypdfs/1/edit
    def edit
      @menu = "mytemplate"
      @board = "mypdf"
      @section = "edit"
            
      @mypdf = Mypdf.get(params[:id])
    end

    def create
      mypdf_id = params[:mypdf_id]
      @mypdf = Mypdf.get(mypdf_id)
      pdf_path = @mypdf.basic_path + @mypdf.pdf_filename
      
      @myimage = Myimage.new
      @myimage.user_id = current_user.id      
      @myimage.name = @mypdf.pdf_filename.gsub(/.pdf/,'')
      
      image_path = @myimage.image_path
      @temp_filename = @mypdf.pdf_filename
      
      while File.exist?(image_path + "/" + @temp_filename) 
        ext_name = File.extname(@temp_filename)
        file_name = @temp_filename.gsub(ext_name,'')

        @temp_filename = file_name + "_1" + ext_name
        @myimage.image_filename = @temp_filename
      end      

      ext_name = File.extname(@temp_filename)      
      file_name = @temp_filename.gsub(ext_name,'')

      @myimage.type = "pdf"
      @myimage.folder = "photo" 
      @myimage.image_filename = @temp_filename
      @myimage.image_thumb_filename = file_name + ".jpg"
      
      if @myimage.save
        
        if File.exist?(pdf_path)
          FileUtils.cp_r pdf_path, image_path + "/" + @mypdf.pdf_filename
          puts %x[#{RAILS_ROOT}"/lib/thumbup" #{pdf_path} #{image_path + "/preview/" + file_name + ".jpg"} 0.5 #{image_path + "/thumb/" + file_name + ".jpg"} 128]            	            
        end
        
        redirect_to mypdfs_path
      else
        puts_message "저장실패!"
        render 'mypdf'
      end
      

    end
    
    # PUT /mypdfs/1
    # PUT /mypdfs/1.xml
    def update
      @menu = "mytemplate"
      @board = "mypdf"
      @section = "edit"
            
      @mypdf = Mypdf.get(params[:id])

      if @mypdf.save
        redirect_to mypdfs_url
      else
        render 'mypdf'
      end

    end

    # DELETE /mypdfs/1
    # DELETE /mypdfs/1.xml
    def destroy
      @mypdf = Mypdf.get(params[:id])
      
      pdf_path = @mypdf.basic_path + @mypdf.pdf_filename
      thumb_path = @mypdf.basic_path + @mypdf.pdf_filename.gsub(/.pdf/,'')+"_t"+".jpg"
      preview_path = @mypdf.basic_path + @mypdf.pdf_filename.gsub(/.pdf/,'')+"_p"+".jpg"
            
      if File.exist?(pdf_path) && File.exist?(thumb_path) && File.exist?(preview_path)         
        File.delete(pdf_path)   
        File.delete(thumb_path)   
        File.delete(preview_path)   
        
      else
        puts_message "PDF 파일이 존재하지 않습니다!"
      end

      @mypdf.destroy
      redirect_to mypdfs_url

    end
    
    def copySelection 

      chk = params[:chk]
      mybook_id =  params[:_book]
      folder_name = Mybook.get(mybook_id.to_i).folder_name
      
      if !chk.nil? 
        mybookpdf = Mybookpdf.first(:user_id => current_user.id, :mybook_id => mybook_id.to_i, :order => [:order.desc])
        
        if mybookpdf != nil
          max_order = mybookpdf.order
        else
          max_order = 0
        end
        order =  max_order + 1        
        chk.each do |chk|
          # PDF 복제 루틴 =========================================================
          # 1. create a new mybookpdf file
          @mybookpdf = Mybookpdf.new
          
          @mypdf = Mypdf.get(chk.to_i)
      
          # 2. copy basic information from original pdf file
          @mybookpdf.pdf_filename = @mypdf.pdf_filename
          @mybookpdf.name = @mypdf.name
          @mybookpdf.description = @mypdf.description
          
          @mybookpdf.folder_name = folder_name
          @mybookpdf.user_id = current_user.id
          @mybookpdf.mybook_id = mybook_id.to_i
          @mybookpdf.order = order
          
          # 3. make a folder (if there is not same named folder)
          dir = "#{RAILS_ROOT}" + "/public/user_files/#{current_user.userid}/mybook/#{folder_name}/"
          FileUtils.mkdir_p dir if not File.exist?(dir)
          FileUtils.chmod 0777, dir
          
      
          # 4. copy phisical file to selected folder(or was made)
          # - 원본의 파일경로 
          original_path = @mypdf.pdf_path[0] + '/' + @mypdf.pdf_filename
          puts_message original_path
          
          # - 복사대상의 파일경로 
          destination_path = dir
          
          if File.exist?(original_path) 
            FileUtils.cp_r original_path,  dir + @mybookpdf.pdf_filename
            FileUtils.cp_r @mypdf.thumb_path,  dir + @mybookpdf.pdf_filename.gsub('.pdf','') + "_t.jpg"
            FileUtils.cp_r @mypdf.preview_path,  dir + @mybookpdf.pdf_filename.gsub('.pdf','') + "_p.jpg"            
          end
          
          if @mybookpdf.save
            puts_message "saved"
          else
            puts_message "not saved"
            puts @mybookpdf.errors
          end
          
           
          order += 1
        end
      
      else
          flash[:notice] = '복사할 파일을 선택하지 않으셨습니다!'    
      end

      redirect_to(mypdfs_url)  
     end

     def deleteSelection  
       mybook_id = params[:mybook_id].to_i
       chk = params[:pdf_id].split(',')

       if !chk.nil? 

         chk.each do |c|
           @mypdf = Mypdf.get(c.to_i)

           pdf_path = @mypdf.basic_path + @mypdf.pdf_filename
           thumb_path = @mypdf.basic_path + @mypdf.pdf_filename.gsub(/.pdf/,'')+"_t"+".jpg"
           preview_path = @mypdf.basic_path + @mypdf.pdf_filename.gsub(/.pdf/,'')+"_p"+".jpg"

           if File.exist?(pdf_path) && File.exist?(thumb_path) && File.exist?(preview_path)         
             File.delete(pdf_path)   
             File.delete(thumb_path)   
             File.delete(preview_path)   
           end

           @mypdf.destroy
         end
        end

        @mypdfs = Mypdf.all(:user_id => current_user.id, :order => [:created_at.desc]).search(params[:search], params[:page])   

        render :update do |page|
          page.replace_html 'partial_page', :partial => 'mypdf_partial', :object => @mypdfs
        end
       end
       

    
  end
