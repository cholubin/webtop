module AdminsessionsHelper
  
  def admin_sign_in(admin)
      admin.remember_me!
#      session[:ad_remember_token1] = { :value => "멋죠?"}
      cookies[:ad_remember_token] = { :value => admin.ad_remember_token, :expires => 1.hour.from_now }
      self.current_admin = admin
  end
  
  def current_admin=(admin)
    @current_admin = admin
  end
  
  def current_admin
      @current_admin ||= admin_from_ad_remember_token
  end
  
  def admin_from_ad_remember_token
      # ad_remember_token = session[:ad_remember_token]
      ad_remember_token = cookies[:ad_remember_token]
      Myadmin.first(:ad_remember_token => ad_remember_token) unless ad_remember_token.nil?
  end
  
  def admin_signed_in?
      !current_admin.nil?
  end
  
  def admin_sign_out        
    # cookies.delete :ad_remember_token
    
    reset_session
    # session[:ad_remember_token] = nil
    cookies[:ad_remember_token] = nil
    
    self.current_admin = nil
  end 
  
  def authenticate_admin! 
    if !admin_signed_in?
      redirect_to '/admin/login'
    end
  end
  
end
