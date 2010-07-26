# encoding: utf-8
class TempfoldersController < ApplicationController
  before_filter :authenticate_user! 

  def create_folder



    if Tempfolder.all(:name => params[:folder_name]).count < 1
      @tempfolder.name = params[:folder_name]      
      @tempfolder = Tempfolder.new()    
      @tempfolder.user_id = current_user.id

      @tempfolder.save
      @aleready_done = false
    else
      puts_message "이미 생성된 폴더명입니다!"
      @already_done = true
    end

    @tempfolders = Tempfolder.all(:user_id => current_user.id.to_s)
         
    render :update do |page|
      page.replace_html 'folder', :partial => 'folder', :object => @tempfolders, :object => @already_done
      page.replace_html 'folder_select', :partial => 'folder_select', :object => @tempfolders     
    end
  end  

  def update_folder
        
    @tempfolder = Tempfolder.get(params[:folder_id].to_i)
    ori_folder_name = @tempfolder.name
    ren_folder_name = params[:folder_name]    
    @tempfolder.name = ren_folder_name
    

  	if @tempfolder.save
  	  @myimages = Myimage.all(:folder => ori_folder_name)
      @myimages.each do |m|
  	    m.folder = ren_folder_name        
  	    m.save        
      end
    end
    
    @tempfolders = Tempfolder.all(:user_id => current_user.id.to_s)
        
    render :update do |page|
      page.replace_html 'folder', :partial => 'folder', :object => @tempfolders
      page.replace_html 'folder_select', :partial => 'folder_select', :object => @tempfolders     
    end    
  end    



  def destroy_folder

    folder_id = params[:folder_id]    
    @tempfolder = Tempfolder.get(folder_id)
    folder_name = @tempfolder.name
    
    if @tempfolder.destroy
      
      #템플릿 삭제 ========================================================      
          @mytemplates = Mytemplate.all(:folder => folder_name)
    
      if @mytemplates.count > 0
        @mytemplates.each do |m|
          m.folder = "기본"
          m.save
        end      
      end
    
    end
    
    @tempfolders = Tempfolder.all(:user_id => current_user.id.to_s)
        
    render :update do |page|
      page.replace_html 'folder', :partial => 'folder', :object => @tempfolders
      page.replace_html 'folder_select', :partial => 'folder_select', :object => @tempfolders     
    end    
  end
  
end
