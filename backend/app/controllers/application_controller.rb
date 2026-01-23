class ApplicationController < ActionController::API
  include Authentication
  before_action :set_current_user
  before_action :authenticate_user!, unless: :public_action?

  private

  def set_current_user
    @current_user = User.find_by(id: session[:user_id]) if session[:user_id]
  end
  
  def public_action?
    action_name.in?(['login', 'register', 'logout'])
  end
end
