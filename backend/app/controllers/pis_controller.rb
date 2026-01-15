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
  # DESCARREGAR DOCUMENT
  def download
    pi = PI.fing(params[:id])

    pdf = Prawn::Document.new

    pdf.text "PLA DE SUPORT INDIVIDUALITZAT", size:18, style: :bold, align: :center
    pdf.move_down 20

    pdf.text "Descripció: #{pi.description}", size:12
    pdf.move_down 10

    pdf.text "Observacions: #{pi.observations}", size:12
    pdf.move_down 10

    pdf.text "Història mèdica: #{pi.medrec}", size:12
    pdf.move_down 10

    pdf.text "Activitats: #{pi.activities}", size:12
    pdf.move_down 10

    pdf.text "Interacció i tutorial: #{pi.interacttutorial}", size:12
    pdf.move_down 10
    
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
