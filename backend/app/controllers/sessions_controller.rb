class SessionsController < ApplicationController
  skip_before_action :authenticate_user!

  def create
    user = User.find_by(email: params[:email])&.authenticate(params[:password])

    if user
      session[:user_id] = user.id
      redirect_to "/up"
    else
      render json: { error: "Invalid credentials" }, status: :unauthorized
    end
  end

  def destroy
    reset_session
    head :no_content
  end
end
