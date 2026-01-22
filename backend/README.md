# Backend - API Rails

## Descripció
Aquesta és l'API backend desenvolupada amb Ruby on Rails 8, que proporciona serveis per a la gestió d'usuaris, pujada de documents PDF, processament i distribució a professors.

## Estructura del Projecte

```
backend/
├── app/
│   ├── controllers/         # Controladors de l'API
│   │   ├── users_controller.rb      # Autenticació d'usuaris
│   │   ├── teachers_controller.rb   # Gestió de professors
│   │   ├── upload_files_controller.rb # Pujada de fitxers
│   │   ├── pis_controller.rb        # Gestió de PI (documents personals)
│   │   └── pis_pdf_controller.rb    # Generació i descàrrega de PDFs
│   ├── models/              # Models de dades
│   │   ├── user.rb          # Model d'usuari (estudiant)
│   │   ├── teacher.rb       # Model de professor
│   │   ├── pi.rb            # Model de document personal
│   │   └── pdf_upload.rb    # Model de pujada de PDF
│   ├── jobs/                # Treballs en segon pla
│   │   └── summarize_pdf_job.rb     # Processament de PDFs
│   ├── services/            # Serveis de lògica de negoci
│   └── views/               # Vistes (JSON responses)
├── config/
│   ├── routes.rb            # Definició de rutes
│   ├── environments/        # Configuracions per entorn
│   └── initializers/        # Inicialitzadors
├── db/                     # Migracions i seeds
├── test/                   # Tests
└── Gemfile                 # Dependències Ruby
```

## Flux de l'Aplicació

1. **Autenticació**:
   - `POST /register`: Registre d'estudiants
   - `POST /login`: Login d'usuaris (estudiants/professors)
   - `POST /logout`: Logout
   - `GET /me`: Informació de l'usuari actual

2. **Gestió de Documents**:
   - `POST /upload`: Pujada de fitxers PDF per estudiants
   - Processament asíncron via `SummarizePdfJob` (Active Job)
   - Emmagatzematge de documents processats com a PI (Personal Information)

3. **Accés de Professors**:
   - `GET /teacher/students`: Llista d'estudiants assignats
   - `GET /teacher/students/:id/document`: Accés als documents d'un estudiant

4. **Descàrrega de Documents**:
   - `GET /pis/:id/download`: Descàrrega de PI en format PDF
   - `GET /pis/my-pi/download`: Descàrrega del propi PI

5. **Temps Real**: WebSockets via Action Cable per actualitzacions de processament de PDFs.

## Tecnologies Utilitzades

- **Ruby on Rails 8**: Framework web full-stack
- **PostgreSQL**: Base de dades
- **Active Job**: Processament en segon pla
- **Action Cable**: WebSockets per comunicació temps real
- **Wicked PDF**: Generació de PDFs
- **PDF Reader**: Lectura i processament de PDFs
- **Puma**: Servidor web
- **Rack CORS**: Gestió de CORS

## Rutes Principals

- **Autenticació**: `/login`, `/logout`, `/register`, `/me`
- **Pujada**: `/upload`
- **PI Management**: `/pis/*`
- **Professors**: `/teacher/*`
- **Salut**: `/up` (health check)

## Variables d'Entorn

Configura les següents variables al fitxer `.env`:

- `DATABASE_URL`: URL de connexió a PostgreSQL
- `SECRET_KEY_BASE`: Clau secreta per Rails
- `WKHTMLTOPDF_PATH`: Ruta a wkhtmltopdf per generació de PDFs