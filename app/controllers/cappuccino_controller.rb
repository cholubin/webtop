# encoding: utf-8
require 'rubygems'
require 'zip/zip'

class CappuccinoController < ApplicationController   
  before_filter :authenticate_user!
  layout "no_layout"
  
  def index
    render :layout => 'cappuccino_ui' 
  end
  
  def show_cappuccino_ui
    @menu = "mlayout"
    @userid = current_user.userid
    
    # 인코딩 
    
    filename = Mytemplate.get(params[:doc_name].to_i).file_filename.gsub(/.mlayoutP.zip/,'')
    
    puts_message Mytemplate.get(params[:doc_name].to_i).file_filename.gsub(/.mlayoutP.zip/,'')
    # 파일명이 아이디와 동일하지 않는 경우 처리 (후에는 삭제처리 한다.)
    if params[:doc_name] != filename
      my = Mytemplate.get(params[:doc_name].to_i)
      original_path = my.path
      my.path = my.path.gsub(filename, my.id.to_s)
      my.thumb_url = my.thumb_url.gsub(filename, my.id.to_s)
      my.preview_url = my.preview_url.gsub(filename, my.id.to_s)
      my.file_filename = my.file_filename.gsub(filename, my.id.to_s)      
      my.save
      
      File.rename original_path, my.path
    end

    if params[:doc_name] != nil
      @doc_name = Mytemplate.get(params[:doc_name].to_i).file_filename.gsub(/.zip/,'')
    end

    
    if @doc_name == nil
      @doc_name = @doc
    end
    
    render :layout => 'cappuccino'
    # render :layout => 'application'
  end             
  
  def post_mlayout
    puts_message "post_mlayout start"                 
    requested_action = params[:requested_action]
    docname = params[:docname]
    userinfo = params[:userinfo] 

    id = docname + ".zip"    
    
    @user = current_user
    # mytemplate = @user.mytemplates.get(id)
    # tpl = Temp.get(mytemplate.temp_id)
    mytemplate = Mytemplate.first(:file_filename => id, :user_id => @user.id)    
    path = "#{RAILS_ROOT}/public/user_files/" + current_user.userid + "/article_templates/" + mytemplate.file_filename.gsub(/.zip/,'')
    xml_file= <<-EOF
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Action</key>
      <string>#{requested_action}</string>
      <key>DocPath</key>
      <string>#{path}</string>   
      <key>ID</key>
      <string>#{mytemplate.id}</string>      
      <key>UserInfo</key>
      <string>#{userinfo}</string>
    </dict>
    </plist>
      
    EOF
    
    
     job_to_do = (path + "/requested_#{requested_action}_job.mJob")
     File.open(job_to_do,'w') { |f| f.write xml_file }    
     erase_job_done_file(mytemplate)
     system "open #{job_to_do}"
     check_done(mytemplate)  
     
     if requested_action == "SetContents" 
        # Mytemplate.process_index_thumbnail(id.gsub(/.zip/,''))  
     end   
       
    # render :layout => 'application'    
    puts_message "post_mlayout end"
  end

  def request_mlayout        
    puts_message "request_mlayout start"                     
    requested_action = params[:requested_action]
    puts "Action Name: " + requested_action
    docname = params[:docname] 
    userinfo = params[:userinfo] 
    id = docname
        
    @user = current_user
    # puts_message @user.userid
    mytemplate = Mytemplate.first(:id => id.to_i, :user_id => @user.id)
    path = mytemplate.path
    
    # path = path.force_encoding("UTF-8").encode!
    # path = CGI::escape(path).gsub(/%2F/,'/').gsub(/%3F/,'?').gsub(/%3D/,'=').gsub(/%26/,'&') 

    
    xml_file= <<-EOF
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Action</key>
      <string>#{requested_action}</string>
      <key>DocPath</key>
      <string>#{path}</string>   
      <key>ID</key>
      <string>#{mytemplate.id}</string>      
      <key>UserInfo</key>
      <string>#{userinfo}</string>
    </dict>
    </plist>
      
    EOF
    
    
     job_to_do = (path + "/requested_#{requested_action}_job.mJob")
     
     puts "job to do:  " + job_to_do
     File.open(job_to_do,'w') { |f| f.write xml_file }    
     erase_job_done_file(mytemplate)
     system "open #{job_to_do}"
     check_done(mytemplate)   

    puts_message "request_mlayout end"        
  end

  def erase_job_done_file(mytemplate)   
    puts_message "erase_job_done_file start"
    # tpl = Temp.get(mytemplate.temp_id) 
    path = mytemplate.path
    job_done = path + "/web/done.txt" 
    if File.exists?(job_done)
      FileUtils.remove_entry_secure(job_done)
    end
    puts_message "erase_job_done_file end"    
  end
  
  def send_result(mytemplate)  
    puts_message "send_resultsend_resultsend_resultsend_resultsend_result"
    # tpl = Temp.get(mytemplate.temp_id)
    path = mytemplate.path
    dat_file = path + "/web/result.dat"
    data = ""                             
    if File.exists?(dat_file)
      File.open(dat_file) do |f|
        f.each{|line| data << line}
      end                   
    else
      data = "no dat file."
    end
    puts_message data
    render :text => data
    # render :text => "hellow"
    # puts_message "send_result end"        
  end
  
  def check_done(mytemplate)     
    puts_message "check_done start"        
     # tpl = Mytemplate.get(mytemplate.temp_id)  
     path = mytemplate.path
     job_done = path + "/web/done.txt"             
     
     time_after_30_seconds = Time.now + 30.seconds     

     while Time.now < time_after_30_seconds
       break if File.exists?(job_done)
     end
     
     if !File.exists?(job_done)
       pid = `ps -c -eo pid,comm | grep MLayout`.to_s
       pid = pid.gsub(/MLayout 2/,'').gsub(' ', '')
       system "kill #{pid}"     
       puts_message "Mlayout was killed!!!!! ============"
     end
     
     # loop do 
     #    break if File.exists?(job_done)
     # end   
     send_result(mytemplate) 
    puts_message "check_done end"        
  end     
  
  
  # check #absolute_path to modify result of roo
  def filelist
    puts_message "filelist start"   
    
    user = current_user
    request = params[:request]
    puts request
    if user and check_existance_of_path(request)    
     if request == nil
       @file_names = 'error'
     elsif request_is_directory?(request)
        fire_the_list(request)
       # @file_names = absolute_path(request)
     elsif request_is_file?(request)
       last = request.split('/').last
       path = absolute_path(request)
       send_file_info(last, request)  
     else
       @file_names = 'error'
     end
    else                                                    
      @file_names = 'error'
    end

    puts_message "filelist end"       
    return @file_names

  end
  
  #used at filelist for checking existance of the path
  def check_existance_of_path(path)

    if not path == nil
      question = absolute_path(path)
      File.exists?(question)
    else
      nil
    end
  end
  
  #used at filelist to check if the path is directory 
  def request_is_directory?(path)
    question = absolute_path(path)    
    File.directory?(question)
  end

  #used at filelist to check if the path is file  
  def request_is_file?(path)
    question = absolute_path(path)    
    File.file?(question)    
  end

  #used at filelist to get file list in requested dir 
  def fire_the_list(path)
    @output = <<-END

    END
    dir = absolute_path(path)
    begin            
      @file_names = Dir.entries(dir)
    rescue
      @file_name = "error"
    end
    
    if not @file_names == nil
      @file_names.delete_if{|f| f =~ /^(\.)(.*)/}
      @file_names.each{|f| @output << f + "\n"}
      @file_names = @output 
      @access_url = ""
     else
       @file_names = "error"
       @access_url = ""
     end            
  end

  #used at filelist inorder to send file info if requested path is file   
  def send_file_info(last, path)
    puts_message "send_file_info start"
    if not last == nil
      user = current_user
      @file_names = "#{path.split('/').last}" + "\n"
      # @access_url = "http://graphicartshub.com:4000/user_files/#{user.userid}/templates" + path
      # @access_url = "#{HOSTING_URL}" + "/user_files/"+ "#{user.userid}/mytemplates/" + path      
      @access_url = "#{HOSTING_URL}" + "/user_files/"+ "#{user.userid}" + path            
    else
      @file_names = "error"
      @access_url = ""
    end
    puts_message "send_file_info end"            
  end     

  #used at filelist   
  def absolute_path(path)
    puts_message "absolute_path start"    
    user = current_user    
    # return ("#{RAILS_ROOT}/public/user_files/#{user.userid}/mytemplates/" + path)
    return ("#{RAILS_ROOT}/public/user_files/#{user.userid}/" + path)    
    puts "absolute path: " + "#{RAILS_ROOT}/public/user_files/#{user.userid}/" + path
    puts_message "absolute_path end"       
  end    


#----------------------------------------------------
  def whoami
    user = current_user
    # @user_login = User.get(user.id).userid 
    if user  
      @userid = user.userid    
      @username = user.userid
    else
      return "Please request with userid and passwd"
    end
  end
#----------------------------------------------------
  def user_path
    user = current_user    
    @user_path = "/user_files/#{user.userid}/article_templates/"
    return @user_path, :layout => false
  end 
  
  def user_home
    user = current_user    
    @user_home = "/user_files/#{user.userid}/"
    return @user_home, :layout => false
  end  
#----------------------------------------------------
  def upload_notify
    puts_message "upload_notify start"
    if params[:userid] && params[:path]
      path = "#{RAILS_ROOT}" + "/public/user_files/" + "#{current_user.userid}"+ "/article_template/"+ params[:path]
      file = path.split('/').last 
      destination = path.split('/').delete_if{|x| x == file}.join("/")
      begin
      unzip(path,destination)
        @result = "success"
        # redirect "/", :message => 'unzipping has succeed!'
      rescue
        @result = "success"
        # redirect "/", :message => 'unzipping has failed!'
      end
    end
  end
  
  def unzip(file, destination)
    Zip::ZipFile.open(file) { |zip_file|
      zip_file.each{ |f|
        f_path = File.join(destination, f.name)
        FileUtils.mkdir_p(File.dirname(f_path))
        zip_file.extract(f, f_path) unless File.exist?(f_path)
      }
    }
    FileUtils.rm(file, :force => true)
  end
  
#----------------------------------------------------
# This method is used in mlayout mtransfer bundle
  
  def ftp_access      
    if User.authenticate(:userid => params[:userid], :password => params[:passwd])
      user = current_user
      login  = params[:userid]
      pass = params[:passwd]
      
      @result =
      "OK\n"+
      # "graphicartshub.com\n"+
      "localhost:3000\n"+
      "#{login}\n"+
      "#{pass}\n"+
      "#{login}"
      
    else
      @result = "Failed\n"
    end
    return @result, :layout => false
  end

#----------------------------------------------------
# This method is used for pureftp    
  def ftp_auth
    if User.authenticate(:userid => params[:login], :password => params[:password])

    # if http_authenticate(params[:userid], params[:password])     
      user = current_user

      @output = <<-END
      auth_ok:1
      uid:#{483}
      gid:#{483}
      dir:#{user_files_root(user)}
      end
      END

    else
      # invalid user, so all we need is for auth_ok to be 0
      @output = "auth_ok:0\n" + "end\n"
    end
    return @output, :layout => false
  end
  
  def user_files_root(user)
    ftp_root = "#{RAILS_ROOT}/public/user_files/#{user.userid}"
    user_root = File.join ftp_root, user.userid
    # mkdir_p is like "mkdir -p" - it creates the directory and parents as necessary,
    # doing nothing if they already exist
    if not user_root
      FileUtils.mkdir_p user_root
    end
    user_root
  end
end
