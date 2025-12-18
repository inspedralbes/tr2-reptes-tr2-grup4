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
    end
  end

  # POST /register
  def register
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
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
