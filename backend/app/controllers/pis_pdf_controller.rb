class PisPdfController < PdfRendererController
  before_action :authenticate_user!
  before_action :set_pi_for_current_user

  def download
    if @pi.blank?
      render json: { error: 'No tienes un Plan de Suport Individualitzat aún.' }, status: :not_found
      return
    end

    @pdf_user = current_user

    html = render_to_string(template: "pis_layout/pdf", layout: "layouts/pdf", formats: [:html])
    pdf = WickedPdf.new.pdf_from_string(html, wkhtmltopdf_options)
    send_data pdf, filename: "pi_#{@pi.id}_#{Date.today}.pdf", type: 'application/pdf', disposition: 'attachment'
  end

  private

  def wkhtmltopdf_options
    {
      'page-size': 'A4',
      'margin-top': '0.75in',
      'margin-right': '0.75in',
      'margin-bottom': '0.75in',
      'margin-left': '0.75in'
    }
  end

  def set_pi_for_current_user
    if current_user
      @pi = current_user.pi
      @pi.reload if @pi.present? # Asegurar que tenemos datos frescos de la base de datos
    end
  end

  def authenticate_user!
    render json: { error: 'Debes estar logueado para descargar tu PI.' }, status: :unauthorized if current_user.blank?
  end
end
