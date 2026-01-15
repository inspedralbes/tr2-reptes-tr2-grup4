class PisController < ApplicationController
  before_action :set_pi, only: %i[ show update destroy download ]

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
  # DESCARREGAR DOCUMENT
  def download
    pdf = Prawn::Document.new

    pdf.text "PLA DE SUPORT INDIVIDUALITZAT", size:18, style: :bold, align: :center
    pdf.move_down 20

    pdf.text "Descripció", style: :bold
    pdf.text @pi.description.to_s 
    pdf.move_down 10

    pdf.text "Observacions", style: :bold
    pdf.text @pi.observations.to_s
    pdf.move_down 10

    pdf.text "Història mèdica", style: :bold
    pdf.text @pi.medrec.to_s
    pdf.move_down 10

    pdf.text "Activitats", style: :bold
    pdf.text @pi.activities.to_s
    pdf.move_down 10

    pdf.text "Interacció tutorial", style: :bold
    pdf.text @pi.interacttutorial.to_s
    pdf.move_down 10


    send_data pdf.render, 
      filename: "PI_#{@pi.id}.pdf", 
      type: "application/pdf",
      disposition: "attachment"
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
