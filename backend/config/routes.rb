Rails.application.routes.draw do
  # Rutas para PI (Planes Individualizados)
  resources :pis do
    member do
      get 'download', to: 'pis_pdf#download'
    end
  end

  # Admin - Asignaciones de estudiantes a profesores
  namespace :admin do
    resources :assignments, only: [:index, :create, :update, :destroy] do
      collection do
        get 'available_students', to: 'assignments#available_students'
        get 'available_teachers', to: 'assignments#available_teachers'
      end
    end
    resources :users, only: [:index, :show, :edit, :update, :destroy] do
      member do
        patch 'update_role'
        patch 'assign_to_teacher'
      end
    end
  end

  # Download PI for current user (no ID required)
  get "/pis/my-pi/download", to: "pis_pdf#download", as: :my_pi_download
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Autenticación y sesión
  get "/login", to: "users#login_page"
  post "/login", to: "users#login"
  delete "/logout", to: "users#logout"
  post "/register", to: "users#register"
  get "/me", to: "users#me"

  # Rutas para Teachers
  scope :teacher do
    get "/students", to: "teachers#students"
    get "/students/:id/document", to: "teachers#student_document"
    get "/dashboard", to: "teachers#dashboard"
    post "/assign_student", to: "teachers#assign_student"
  end

  # Rutas para Students (alumnos)
  scope :student do
    get "/dashboard", to: "students#dashboard"
    get "/my-teacher", to: "students#my_teacher"
    get "/my-pi", to: "students#my_pi"
  end

  # Base create and show
  # post "/pis", to: "pi#create"
  # get "/pis", to: "pi#index"
  post "/upload", to: "upload_files#create"
  resources :pdf_uploads, only: [ :show ]

  # Mount Action Cable for WebSocket connections
  # This allows clients to connect to ws://localhost:3000/cable
  # for real-time updates on PDF processing
  mount ActionCable.server => "/cable"

  # Ruta por defecto - redirige según rol del usuario
  # root to: "home#index"
  root to: redirect("/up")
end