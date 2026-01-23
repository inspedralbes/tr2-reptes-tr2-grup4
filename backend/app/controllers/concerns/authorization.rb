module Authorization
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!, unless: :public_action?
  end

  private

  def authenticate_user!
    return if @current_user.present?
    
    render json: { error: "No autenticado", authenticated: false }, status: :unauthorized
  end

  def authorize_student!
    unless @current_user&.student?
      render json: { 
        error: "Solo estudiantes pueden acceder a esta función",
        authenticated: true,
        role: @current_user&.role
      }, status: :forbidden
      return false
    end
    true
  end

  def authorize_teacher!
    unless @current_user&.teacher?
      render json: { 
        error: "Solo profesores pueden acceder a esta función",
        authenticated: true,
        role: @current_user&.role
      }, status: :forbidden
      return false
    end
    true
  end

  def authorize_admin!
    unless @current_user&.admin?
      render json: { 
        error: "Solo administradores pueden acceder a esta función",
        authenticated: true,
        role: @current_user&.role
      }, status: :forbidden
      return false
    end
    true
  end

  def public_action?
    action_name.in?(['login', 'register', 'logout', 'login_page'])
  end
end
