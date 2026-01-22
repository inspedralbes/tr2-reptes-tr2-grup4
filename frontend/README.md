# Frontend - Aplicació Nuxt.js

## Descripció
Aquesta és l'aplicació frontend desenvolupada amb Nuxt 4 i Vue.js, utilitzant Tailwind CSS per als estils. Serveix com a interfície d'usuari per a estudiants i professors en un sistema de gestió de documents.

## Estructura del Projecte

```
frontend/
├── app/
│   ├── app.vue              # Component principal de l'aplicació
│   ├── assets/              # Recursos estàtics (CSS, imatges)
│   ├── composables/         # Composables de Vue (lògica reutilitzable)
│   ├── layouts/             # Layouts de pàgina
│   └── pages/               # Pàgines de l'aplicació
│       ├── index.vue        # Pàgina d'inici
│       ├── login.vue        # Pàgina de login per estudiants
│       ├── loginTeacher.vue # Pàgina de login per professors
│       ├── register.client.vue # Registre per estudiants
│       ├── upload.vue       # Pàgina de pujada de documents
│       ├── private.client.vue # Àrea privada d'estudiants
│       ├── teacher.client.vue # Àrea privada de professors
│       └── areaPrivada.vue  # Àrea privada general
├── public/                  # Recursos públics
├── nuxt.config.ts           # Configuració de Nuxt
├── tailwind.config.ts       # Configuració de Tailwind CSS
└── package.json             # Dependències i scripts
```

## Flux de l'Aplicació

1. **Pàgina d'Inici (index.vue)**: Punt d'entrada on els usuaris poden triar entre login d'estudiant o professor.

2. **Autenticació**:
   - **Estudiants**: Registre via `register.client.vue` i login via `login.vue`
   - **Professors**: Login via `loginTeacher.vue`

3. **Àrea Privada d'Estudiants**:
   - `private.client.vue`: Visualització i gestió dels seus propis documents
   - `upload.vue`: Pujada de fitxers PDF per processar

4. **Àrea Privada de Professors**:
   - `teacher.client.vue`: Visualització dels documents dels estudiants assignats

5. **Processament**: Els documents pujats s'envien al backend per a processament i resum automàtic via WebSockets.

## Tecnologies Utilitzades

- **Nuxt 4**: Framework Vue.js amb SSR
- **Vue 3**: Framework JavaScript progressiu
- **Tailwind CSS**: Framework CSS utilitari
- **TypeScript**: Tipatge estàtic per JavaScript

## Scripts Disponibles

- `npm run dev`: Inicia el servidor de desenvolupament
- `npm run build`: Construeix l'aplicació per producció
- `npm run preview`: Previsualitza la construcció de producció