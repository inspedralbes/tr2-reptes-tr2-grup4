class UsersController < ApplicationController
  # GET /login - ruta para validar si está logueado
  def login_page
    if session[:user_id]
      user = User.find_by(id: session[:user_id])
      render json: { authenticated: true, role: user&.role }, status: :ok
    else
      render json: { authenticated: false }, status: :ok
    end
  end

  # POST /login
  def login
    user = User.find_by(username: params[:username])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      render json: { 
        authenticated: true, 
        role: user.role,
        user: {
          id: user.id,
          username: user.username,
          email: user.email
        }
      }, status: :ok
    else
      reset_session
      render json: { error: "Invalid email or password", authenticated: false }, status: :unauthorized
    end
  end

  # POST /register
  def register
    # Si se proporciona un rol, usarlo; si no, por defecto es "student"
    role = params[:role] || "student"
    
    # Validar que el rol sea válido
    unless %w[student teacher].include?(role)
      return render json: { 
        error: "Invalid role. Must be 'student' or 'teacher'",
        authenticated: false 
      }, status: :unprocessable_entity
    end

    @user = User.new(user_params.merge(role: role))

    if @user.save
      # Log the user in automatically
      session[:user_id] = @user.id
      render json: {
        id: @user.id,
        username: @user.username,
        email: @user.email,
        role: @user.role,
        message: "User registered successfully"
      }, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # POST /logout
  def logout
    reset_session
    render json: { authenticated: false }, status: :ok
  end

  # GET /me
  def me
    if session[:user_id]
      user = User.find_by(id: session[:user_id])
      if user
        render json: {
          authenticated: true,
          user: {
            id: user.id,
            username: user.username,
            email: user.email,
            role: user.role
          }
        }, status: :ok
      else
        reset_session
        render json: { authenticated: false }, status: :unauthorized
      end
    else
      render json: { authenticated: false }, status: :unauthorized
    end
  end

  private

  def user_params
    params.permit(:username, :email, :password, :password_confirmation, :role)
  end
end