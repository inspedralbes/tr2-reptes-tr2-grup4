Rails.application.routes.draw do
  scope :api do
    resources :pis do
      member do
        get "download", to: "pis_pdf#download"
      end
    end

    # Download PI for current user (no ID required)
    get "pis/my-pi/download", to: "pis_pdf#download", as: :my_pi_download

    # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
    # Mount Action Cable for WebSocket connections
    # This allows clients to connect to ws://localhost:3000/cable
    # for real-time updates on PDF processing
    mount ActionCable.server => "cable"
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
    # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
    # Can be used by load balancers and uptime monitors to verify that the app is live.
    get "up" => "rails/health#show", as: :rails_health_check

    # Uploads
    post "/upload", to: "upload_files#create"
    resources :pdf_uploads, only: [ :show ]
  end
end
