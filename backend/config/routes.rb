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

    # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
    # Can be used by load balancers and uptime monitors to verify that the app is live.
    get "up" => "rails/health#show", as: :rails_health_check

    post "login", to: "users#login"
    post "logout", to: "users#logout"
    post "register", to: "users#register"
    get "me", to: "users#me"
    get "teacher/students", to: "teachers#students"
    get "teacher/students/:id/document", to: "teachers#student_document"



    # Base create and show
    # post "/pis", to: "pi#create"
    # get "/pis", to: "pi#index"
    post "upload", to: "upload_files#create"
    resources :pdf_uploads, only: [ :show ]

    # Mount Action Cable for WebSocket connections
    # This allows clients to connect to ws://localhost:3000/cable
    # for real-time updates on PDF processing
    mount ActionCable.server => "cable"
  end
end
