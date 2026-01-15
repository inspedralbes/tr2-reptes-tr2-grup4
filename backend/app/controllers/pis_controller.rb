class PisController < ApplicationController
  before_action :set_pi, only: %i[ show update destroy ]

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
    #return render json: nil, status: :unauthorized unless current_user
    #pi = current_user.pi
    #return render json: nil, status: :not_found unless pi
    #render json: pi
  end

  # POST /pis
  def create
    if current_user
      @pi = current_user.build_pi(pi_params)

      if @pi.save
        render :show, status: :created, location: @pi
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
      render :show, status: :ok, location: @pi
    else
      render json: @pi.errors, status: :unprocessable_entity
    end
  end

  # DELETE /pis/1
  def destroy
    @pi.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pi
      @pi = Pi.find(params.required(:id))
    end

    # Only allow a list of trusted parameters through.
    def pi_params
      params.required(:pi).permit(:description, :observations, :medrec, :activities, :interacttutorial)
    end
end
