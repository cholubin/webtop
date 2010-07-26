# encoding: utf-8
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
end

def get_current_url
  request.request_uri  
end
# 파일명을 안전하게 변환한다. 한글파일명을 위해 UTF-8 코드는 살려둔다. 
def sanitize_filename(filename)
  filename.force_encoding('UTF-8')
  returning filename.strip do |name|
    # NOTE: File.basename doesn't work right with Windows paths on Unix
    # get only the filename, not the whole path
    name.gsub! /^.*(\\|\/)/u, ''

    # Finally, replace all non alphanumeric, underscore or periods with underscore
    name.gsub! /[^ㄱ-ㅎ가-힣0-9A-Za-z\w\.\-]/u, '_'
    # name.gsub! /[^\x{AC00}-\x{D7A3}]/, '_'    
    
  end
end

# 파일명을 안전하게 변환한다. 좀더 엄격하게 영문외의 문자는 모두 날린다. 
def sanitize_filename_restrict(filename)
  returning filename.strip do |name|
   # NOTE: File.basename doesn't work right with Windows paths on Unix
   # get only the filename, not the whole path
   name.gsub! /^.*(\\|\/)/, ''
 
   # Finally, replace all non alphanumeric, underscore or periods with underscore
   #            name.gsub! /[^\w\.\-]/, '_'
   #            Basically strip out the non-ascii alphabets too and replace with x. You don't want all _ :)
    name.gsub!(/[^0-9A-Za-z.\-]/, 'x')
  end
end

def puts_message(message)
  puts "=======================================================\n" + message + "\n======================================================="
end
