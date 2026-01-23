module Authentication
  extend ActiveSupport::Concern
  
  included do
    helper_method :current_user
    helper_method :current_teacher
    helper_method :current_admin
  end
  
  private
  
  def authenticate_user!
    unless current_user || current_teacher || current_admin
      redirect_to login_path, alert: 'Please log in'
    end
  end
  
  def current_user
    if session[:user_id] && session[:user_type] == 'User'
      @current_user ||= User.find_by(id: session[:user_id])
    elsif session[:user_id] && session[:user_type] == 'Teacher'
      @current_user ||= Teacher.find_by(id: session[:user_id])&.as_user
    elsif session[:user_id] && session[:user_type] == 'Admin'
      @current_user ||= Admin.find_by(id: session[:user_id])&.as_user
    end
  end
  
  def current_teacher
    @current_teacher ||= Teacher.find_by(id: session[:user_id]) if session[:user_type] == 'Teacher'
  end
  
  def current_admin
    @current_admin ||= Admin.find_by(id: session[:user_id]) if session[:user_type] == 'Admin'
  end
  
  def require_admin
    unless current_user&.admin? || current_admin
      redirect_to root_path, alert: 'Admin access required'
    end
  end
  
  def require_teacher
    unless current_user&.teacher? || current_teacher
      redirect_to root_path, alert: 'Teacher access required'
    end
  end
end