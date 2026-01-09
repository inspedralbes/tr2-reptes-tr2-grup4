class PisController < ApplicationController
  before_action :set_pi, only: %i[ show update destroy ]

  # GET /pis
  # GET /pis.json
  def index
    @pis = Pi.all
  end

  # GET /pis/1
  # GET /pis/1.json
  def show
  end

  # POST /pis
  # POST /pis.json
  def create
    @pi = Pi.new(pi_params)

    if @pi.save
      render :show, status: :created, location: @pi
    else
      render json: @pi.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /pis/1
  # PATCH/PUT /pis/1.json
  def update
    if @pi.update(pi_params)
      render :show, status: :ok, location: @pi
    else
      render json: @pi.errors, status: :unprocessable_entity
    end
  end

  # DELETE /pis/1
  # DELETE /pis/1.json
  def destroy
    @pi.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pi
      @pi = Pi.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def pi_params
      params.expect(pi: [ :description, :observations, :medrec, :activities, :interacttutorial ])
    end
end
