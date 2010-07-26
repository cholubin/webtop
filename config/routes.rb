ActionController::Routing::Routes.draw do |map|
  map.resources :mybooks,:mybookpdfs, :mybookfolders

  map.resources :tempfolders

  map.resources :folders  
  map.resources :mypdfs
  map.resources :myadmins
  map.resources :adminsessions  

  map.resources :temps
  # map.resources :temps, :only => [:index, :show]
  map.resources :myimages

  map.resources :mycarts
  map.resources :sessions, :only => [:new, :create, :destory]
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'

  map.login '/admin/login', :controller => 'adminsessions', :action => 'new'
  map.login '/admin', :controller => 'adminsessions', :action => 'new'
  map.logout '/admin/logout', :controller => 'adminsessions', :action => 'destroy'

  
  map.root :controller => 'Pages', :action => 'home'
  
  # map.resources :pages
  map.resources :subcategories, :categories
  map.resources :categories, :has_many => :subcategories
  map.resources :notices
  map.resources :freeboards, :users
  map.resources :users, :has_many => :freeboards
  map.resources :faqs
  # map.resources :articles

  map.resources :mytemplates
  # map.resources :mytemplates, :path_prefix => '/admin'
  # map.resources :mytemplates, :only => [:index, :show]

  map.namespace :admin do |admin|
      admin.resources :folders, :mypdfs, :users, :temps, :categories, :notices, :freeboards, :myadmins, :faqs, :mytemplates, :myimages
  end 
  
  
  # cappuccino
  map.ftp_auth '/ftp_auth', :controller => 'Cappuccino', :action => 'ftp_auth'
  map.ftp_access '/ftp_access', :controller => 'Cappuccino', :action => 'ftp_access'
  map.upload_notify '/upload_notify', :controller => 'Cappuccino', :action => 'upload_notify'
  map.whoami '/whoami', :controller => "Cappuccino", :action => 'whoami'
  map.user_path '/user_path', :controller => "Cappuccino", :action => 'user_path'
  map.user_home '/user_home', :controller => "Cappuccino", :action => 'user_home'  
  map.filelist '/filelist' , :controller => "Cappuccino", :action => 'filelist'    
  map.request_mlayout '/request_mlayout' , :controller => "Cappuccino", :action => 'request_mlayout'  
  map.post_mlayout '/post_mlayout', :controller => "Cappuccino", :action => 'post_mlayout' #, :member => { :prepare => [:post] }
  map.send_result '/send_result', :controller => "Cappuccino", :action => "send_result"     
  map.cappuccino_full '/mlayout_full', :controller => "Cappuccino", :action => "index"
  map.cappuccino '/mlayout', :controller => "Cappuccino", :action => "show_cappuccino_ui"
      
  map.publish '/publish/:id', :controller => "mytemplates", :action => "publish"
           
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
