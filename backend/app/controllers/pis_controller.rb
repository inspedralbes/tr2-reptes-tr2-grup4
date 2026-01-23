class PisController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_student!, except: %i[show]
  before_action :set_pi, only: %i[show update destroy]

  # GET /pis
  def index
    if current_user
      render json: current_user.pi
    else
      render json: nil, status: :unauthorized
    end
  end

  # GET /pis/1
  def show
    if @pi && (@pi.user_id == current_user.id || current_user.teacher?)
      render json: @pi
    else
      render json: { error: "Not found" }, status: :not_found
    end
  end

  # POST /pis
  def create
    if current_user
      @pi = current_user.build_pi(pi_params)

      if @pi.save
        render json: @pi, status: :created
      else
        render json: @pi.errors, status: :unprocessable_entity
      end
    else
      render json: { error: "Authentication required" }, status: :unauthorized
    end
  end

  # PATCH/PUT /pis/1
  def update
    if @pi.update(pi_params)
      render json: @pi, status: :ok
    else
      render json: { error: @pi.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /pis/1
  def destroy
    @pi.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pi
      @pi = current_user.pi
      render json: { error: "PI no encontrado" }, status: :not_found if @pi.nil?
    end

    # Only allow a list of trusted parameters through.
    def pi_params
      params.required(:pi).permit(:description, :observations, :medrec, :activities, :interacttutorial, :document)
    end
end
