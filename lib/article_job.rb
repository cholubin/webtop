require 'resque'

class CreatingArticleJob
 @queue = :article
 
  def self.perform(article)
   generate_xml(article)   
 
   sleep(15)
   # process_index_thumbnail(article)   
   tmpl = Temp.find_by_article_id(article.id)              
   close_document(tmpl.path)
   puts "Processed a job!"  
  end
end

def delete_template(article)   
  @temp = Temp.find(article.temp_id)
  @temp.destroy  
   if @temp.path && File.exists?(@temp.path) 
      begin
        FileUtils.remove_entry_secure @temp.path             
      rescue
        flash[:notice] = "failed to delete article's template"
      end
    end
end

def reset_imgs(article)
  article.spread_imgs = nil 
  article.spread_imgs_url = nil     
  article.spread_mediums = nil
  article.spread_mediums_url = nil 
  article.spread_thumbs = nil
  article.spread_thumbs_url = nil   
end

# def copy_template(article, tpl_id)                           
#   path = "#{RAILS_ROOT}/public/user_files/" + current_user.userid + "/article_templates"
#   @object_to_clone = Temp.find(tpl_id) 
# 
#   @cloned_object = Temp.new
#   @cloned_object.title = article.title + "-template"
#   @cloned_object.filename = @object_to_clone.filename
#   @cloned_object.after_uploaded_bad_filename = @object_to_clone.after_uploaded_bad_filename
#   @cloned_object.description = @object_to_clone.description
#   @cloned_object.article_id = article.id 
#   @cloned_object.user_id = current_user.id  
#   @cloned_object.userid = current_user.userid  
#   @cloned_object.size = @object_to_clone.size  
#   @cloned_object.type = "article"    
#   @cloned_object.path = path + "/" + article.id.to_s  + ".mlayoutP"   
#   @cloned_object.preview_path = ("#{HOSTING_URL}" + "/user_files/" + current_user.userid + "/article_templates/" + article.id.to_s + ".mlayoutP/web/doc_thumb.jpg")            
#   @cloned_object.save
# 
#   new_temp_dir = path + "/" + article.id.to_s  + ".mlayoutP"
#   FileUtils.mkdir_p(File.dirname(new_temp_dir))   
#   FileUtils.cp_r @object_to_clone.path, new_temp_dir  
#   #--- delete template's mjob file     
#   tmp = new_temp_dir + "/do_job.mjob"
#   FileUtils.remove_entry_secure(tmp) if File.exist?(tmp)  
#   article.temp_id = @cloned_object.id   
#   article.save                            
#   # get_previews(article) 
# 
# end     

def generate_xml(article)    
  xml_file = <<-EOF
  <xml>
    <title>#{article.title}</title>
    <subtitle>#{article.subtitle}</subtitle>
    <lead>#{article.lead}</lead>
    <author>#{article.author}</author>
    <body>#{article.body_html}</body>  
  </xml>
  EOF
         
  @tpl = Temp.find(article.temp_id)   
  path = @tpl.path              
  write_2_file =  path + "/web/contents.xml"      
  File.open(write_2_file,'w') { |f| f.write xml_file }

  #================
 
  
  xml_file= <<-EOF
  <?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
  <plist version="1.0">
  <dict>
  	<key>Action</key>
  	<string>RefreshXML</string>
  	<key>DocPath</key>
  	<string>#{path}</string>
  </dict>
  </plist>

  EOF
  

   job_to_do = (path + "/refresh_xml_job.mJob")
   File.open(job_to_do,'w') { |f| f.write xml_file }    

   system "open #{job_to_do}"
  
  #================

end 

def close_document(path)
  close_xml= <<-EOF
  <?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
  <plist version="1.0">
  <dict>
  	<key>Action</key>
  	<string>CloseDocument</string>
  	<key>DocPath</key>
  	<string>#{path}</string>
  </dict>
  </plist>

  EOF
  close_job_file = (path + "/close_job.mJob") 
  File.open(close_job_file,'w') { |f| f.write close_xml } 
  system "open #{close_job_file}"
end

  
def publish_mjob(article)    
  target_template = Temp.find(article.temp_id)
  goal = target_template.path    
  
  xml_file = <<-EOF
  <?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
  <plist version="1.0">
  <dict>
  	<key>Action</key>
  	<string>SaveDocumentPDF</string>
  	<key>DocPath</key>
  	<string>#{goal}</string>
  </dict>
  </plist>
 
  EOF
  
  njob = target_template.path + "/publish_job.mJob" 
  File.open(njob,'w') { |f| f.write xml_file }    
  # process_index_thumbnail(target_template.path) 
  system "open #{njob}"
   get_the_pdf(article)   
end    

def get_the_pdf(article)
  pdf = "#{RAILS_ROOT}" + "/public/user_files/" + current_user.userid + "/article_templates/" + "#{article.id}" +".mlayoutP/web/document.pdf"
  url = "#{HOSTING_URL}" + "/user_files/" + current_user.userid + "/article_templates/" + "#{article.id}" +".mlayoutP/web/document.pdf" 
  article.pdf = url 
  article.pdf_path = pdf
  article.save  
end
    

# def process_index_thumbnail(article) 
#   # tmpl = Temp.find_by_article_id(article.id) 
#   # path = tmpl.path  
# 
#   base_dir = "#{RAILS_ROOT}" + "/public/user_files/" + current_user.userid + "/article_templates/" + "#{article.id}" +".mlayoutP/web/"
#   previews = Dir.new(base_dir).entries.sort.delete_if{|x| !(x =~ /jpg$/)}.delete_if{|x| !(x =~ /spread_preview/)}   
#   base_url = "#{HOSTING_URL}" + "/user_files/" + current_user.userid + "/article_templates/" + "#{article.id}" + ".mlayoutP/web/"
#   index = 1   
#      
#   previews.each do |spread| 
#     source_img = base_dir + spread
#     preview_filename = spread
#     medium_filename = ("spread_medium_000" + (index).to_s + ".jpg")
#     thumb_filename = ("spread_thumb_000" + (index).to_s + ".jpg")
#     
#     resize_and_write(source_img, base_dir + medium_filename, "medium")
#     # resize_and_write(source_img, base_dir + thumb_filename , "thumb")
#             
#     article.spread_imgs << base_dir + preview_filename
#     article.spread_imgs_url << base_url + preview_filename
#     article.spread_mediums << base_dir + medium_filename
#     article.spread_mediums_url << base_url + medium_filename
#     article.spread_thumbs << base_dir + thumb_filename
#     article.spread_thumbs_url << base_url + thumb_filename 
#     index += 1             
#   end 
#   article.save
# end   
# 
# def resize_and_write(source_img, output, size)
#   case size
# 
#   when "medium"
#     processed_img = Miso::Image.new(source_img) 
#     processed_img.crop(280, 124) 
#     processed_img.fit(280, 124)
#     processed_img.write(output)            
#   when "thumb"
#     # processed_img = Miso::Image.new(source_img) 
#     # processed_img.crop(140, 62) 
#     # processed_img.fit(140, 62)
#     # processed_img.write(output)      
#   else "error"
#     # throw error
#   end
# end