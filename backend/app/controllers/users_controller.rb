class UsersController < ApplicationController
  # before_action :set_user, only: %i[ show update destroy ]

  # POST /login
  def login
    user = User.find_by(username: params[:username])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      render json: { authenticated: true }, status: :ok
    else
      render json: { error: "Invalid email or password", authenticated: false }, status: :unauthorized
      reset_session
    end
  end

  # POST /register
  def register
    @user = User.new(user_params)

    if @user.save
      # Log the user in automatically
      session[:user_id] = @user.id
      render json: @user, status: :created
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
          id: user.id
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

# GET /teacher/students
def teacher_students
  user = User.find_by(id: session[:user_id])
  return render json: { error: "Unauthorized" }, status: :unauthorized unless user

  return render json: { error: "Forbidden" }, status: :forbidden unless user.role == "teacher"

  render json: user.students.as_json(only: [:id, :username, :email]), status: :ok
end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  # def update
  #  if @user.update(user_params)
  #    render :show, status: :ok, location: @user
  #  else
  #    render json: @user.errors, status: :unprocessable_entity
  #  end
  # end

  # DELETE /users/1
  # DELETE /users/1.json
  # def destroy
  #  @user.destroy!
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.permit(:username, :email, :password, :password_confirmation)
    end
end