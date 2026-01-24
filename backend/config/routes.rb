Rails.application.routes.draw do
  resources :pis do
    member do
      get 'download', to: 'pis_pdf#download'
    end
  end
  
  # Download PI for current user (no ID required)
  get "/pis/my-pi/download", to: "pis_pdf#download", as: :my_pi_download
  
  # Authentication routes
  get "/login", to: "users#login_page"
  post "/login", to: "users#login"
  post "/logout", to: "users#logout"
  post "/register", to: "users#register"
  get "/me", to: "users#me"
  
  # Teacher routes
  get "/teacher/students", to: "teachers#students"
  get "/teacher/students/:id/document", to: "teachers#student_document"
  get "/teacher/students/:id/summary", to: "teachers#student_summary"
  post  "/teacher/students/:id/document", to: "teachers#upload_student_document"
  get   "/teacher/students/:id/document/download", to: "teachers#download_student_document"
  patch "/teacher/students/:id/pi", to: "teachers#update_student_pi"
  
  # Admin routes
  get "/admin/assignments", to: "admin#assignments"
  patch "/admin/assignments/:id", to: "admin#update_assignment"
  
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Uploads
  post "/upload", to: "upload_files#create"
  resources :pdf_uploads, only: [ :show ]

  # Mount Action Cable for WebSocket connections
  mount ActionCable.server => "/cable"
end
