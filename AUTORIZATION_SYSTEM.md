# Sistema de Autorización por Roles

## Estructura de Roles

El sistema implementa 3 roles principales:

- **student**: Estudiantes que pueden ver y editar su propio PI
- **teacher**: Profesores que pueden ver estudiantes y sus PIs
- **admin**: Administradores (reservado para futuro)

## Backend - Flujo de Autenticación

### 1. Módulo de Autorización (`app/controllers/concerns/authorization.rb`)

Incluido automáticamente en `ApplicationController`, proporciona:

- `authenticate_user!` - Verifica que el usuario esté logueado
- `authorize_student!` - Solo permite estudiantes
- `authorize_teacher!` - Solo permite profesores  
- `authorize_admin!` - Solo permite administradores
- `public_action?` - Rutas públicas que no requieren autenticación

### 2. Controlador de Usuarios

**POST /login** - Login
```json
{
  "username": "student_username",
  "password": "password123"
}
```

Respuesta:
```json
{
  "authenticated": true,
  "role": "student",
  "user": {
    "id": 1,
    "username": "student_username",
    "email": "student@example.com"
  }
}
```

**POST /register** - Registro con rol
```json
{
  "username": "new_student",
  "email": "student@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "role": "student"  // o "teacher"
}
```

Roles válidos: `student`, `teacher`

**GET /me** - Verificar usuario actual
Respuesta:
```json
{
  "authenticated": true,
  "user": {
    "id": 1,
    "username": "student_username",
    "email": "student@example.com",
    "role": "student"
  }
}
```

### 3. Protección de Rutas en Backend

Ejemplo en `PisController`:

```ruby
class PisController < ApplicationController
  before_action :authenticate_user!           # Requiere login
  before_action :authorize_student!           # Solo estudiantes
  
  def index
    render json: current_user.pi
  end
end
```

## Frontend - Flujo de Autenticación

### 1. Páginas de Login

**`/login`** - Login para estudiantes
- Valida que `role === "student"`
- Redirige a `/private` si es válido
- Muestra error si es otro rol

**`/loginTeacher`** - Login para profesores
- Valida que `role === "teacher"`
- Redirige a `/teacher` si es válido
- Muestra error si es otro rol

**`/loginAdmin`** - Login para admin (si existe)
- Valida que `role === "admin"`

### 2. Páginas de Registro

**`/register`** - Registro de estudiantes
- Especifica `role: "student"` en el POST
- Redirige a `/private` después del éxito

**`/registerTeacher`** - Registro de profesores
- Especifica `role: "teacher"` en el POST
- Redirige a `/loginTeacher` después del éxito

### 3. Composable de Autorización

Uso en componentes:

```typescript
<script setup lang="ts">
import { useAuthorization } from '~/composables/useAuthorization';

const { checkAuthorization } = useAuthorization('student');

onMounted(async () => {
  const auth = await checkAuthorization();
  if (!auth.authenticated) {
    // Usuario no autenticado o rol incorrecto
    return;
  }
  
  console.log(`Usuario ${auth.user?.username} con rol ${auth.role}`);
});
</script>
```

## Flujo de Usuario Típico

### Estudiante
1. Accede a `/` (página inicial)
2. Clica en "Registrarse como Estudiante"
3. Completa formulario de registro
4. Se le asigna automáticamente `role: student`
5. Es redirigido a `/private`
6. Ve su PI

### Profesor
1. Accede a `/loginTeacher`
2. Clica en "¿No tienes cuenta? Regístrate como profesor"
3. Es redirigido a `/registerTeacher`
4. Completa formulario de registro
5. Se le asigna automáticamente `role: teacher`
6. Es redirigido a `/loginTeacher` (para confirmar login)
7. Inicia sesión y es redirigido a `/teacher`

## Mensajes de Error

Si un usuario intenta acceder con rol incorrecto:

**Backend**
```json
{
  "error": "Solo estudiantes pueden acceder a esta función",
  "authenticated": true,
  "role": "teacher",
  "status": 403
}
```

**Frontend**
```
❌ Error: Eres teacher. Este login es solo para estudiantes. 
Por favor, usa el login correcto.
```

## Endpoints por Rol

| Endpoint | GET | POST | PATCH | DELETE |
|----------|-----|------|-------|--------|
| `/me` | ✅ (todos) | ✗ | ✗ | ✗ |
| `/pis` | ✅ (student) | ✅ (student) | ✅ (student) | ✅ (student) |
| `/teacher/students` | ✅ (teacher) | ✗ | ✗ | ✗ |
| `/login` | ✗ | ✅ (público) | ✗ | ✗ |
| `/register` | ✗ | ✅ (público) | ✗ | ✗ |
| `/logout` | ✗ | ✅ (todos) | ✗ | ✗ |

## Testing

### Test Login Estudiante
```bash
curl -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -d '{"username":"Student One","password":"password123"}'
```

### Test Login Profesor
```bash
curl -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -d '{"username":"teacher_username","password":"password123"}'
```

### Test Acceso Negado
```bash
# Estudiante intentando acceder a recurso de profesor
curl -X GET http://localhost:3000/teacher/students \
  -H "Cookie: _backend_session=..." \
  -X POST http://localhost:3000/login \
  -d '{"username":"Student One","password":"password123"}' \
  -H "Cookie: _backend_session=..."
```

## Notas de Seguridad

- Las sesiones se basan en cookies seguras
- El servidor valida el rol en cada request
- El frontend también valida el rol para mejor UX
- Las contraseñas se hashean con `bcrypt` automáticamente
- No se retornan contraseñas en respuestas
