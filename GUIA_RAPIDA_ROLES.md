# Guía de Uso - Sistema de Autorización por Roles

## 🎯 Resumen Rápido

Has implementado un **sistema de autenticación y autorización basado en roles** que previene que estudiantes accedan como profesores y viceversa.

```
┌─────────────────────────────────────────────────────────────────┐
│                    FLUJO DE AUTENTICACIÓN                       │
└─────────────────────────────────────────────────────────────────┘

ESTUDIANTE                          PROFESOR
│                                   │
├─ POST /register                  ├─ POST /register
│  (role: "student")               │  (role: "teacher")
│                                   │
├─ GET /login                      ├─ GET /loginTeacher
│  Valida role === "student"       │  Valida role === "teacher"
│                                   │
├─ ✅ Accede a /private            ├─ ✅ Accede a /teacher
│                                   │
└─ ❌ No puede:                    └─ ❌ No puede:
   • Acceder a /loginTeacher         • Acceder a /login
   • Acceder a /loginAdmin           • Acceder a /loginAdmin
   • Ver estudiantes                 • Ver su PI como suyo
```

## 📋 Tabla de Accesos

| Recurso | Estudiante | Profesor | Admin |
|---------|-----------|----------|-------|
| GET /login | ✅ | ❌ | ❌ |
| GET /loginTeacher | ❌ | ✅ | ❌ |
| GET /register | ✅ | ❌ | ❌ |
| GET /registerTeacher | ❌ | ✅ | ❌ |
| GET /pis (su PI) | ✅ | ❌ | ❌ |
| GET /teacher/students | ❌ | ✅ | ❌ |
| POST /logout | ✅ | ✅ | ✅ |
| GET /me | ✅ | ✅ | ✅ |

## 🔒 Validación de Roles

### Backend (Ruby/Rails)

```ruby
# En ApplicationController
include Authorization

# En cada controlador
before_action :authenticate_user!      # ✅ Usuario está logueado
before_action :authorize_student!      # ✅ Usuario es estudiante

# Métodos disponibles
authorize_teacher!  # Solo profesores
authorize_admin!    # Solo administradores
authorize_student!  # Solo estudiantes
```

### Frontend (Vue/TypeScript)

```typescript
// En cada página
const { checkAuthorization } = useAuthorization('student');

onMounted(async () => {
  const auth = await checkAuthorization();
  if (!auth.authenticated) {
    // Redirige si no es el rol correcto
    return;
  }
});
```

## 🚀 Cómo Usar

### 1️⃣ Estudiante Nuevo

```
1. Ir a http://localhost:3001
2. Clica "Registrarse"
3. Completa el formulario
4. Se le asigna automáticamente role: "student"
5. Redirige a /private (área del estudiante)
```

### 2️⃣ Profesor Nuevo

```
1. Ir a http://localhost:3001/loginTeacher
2. Clica "¿No tienes cuenta? Regístrate como profesor"
3. Redirige a http://localhost:3001/registerTeacher
4. Completa el formulario
5. Se le asigna automáticamente role: "teacher"
6. Redirige a /loginTeacher para confirmar
7. Inicia sesión y accede a /teacher
```

### 3️⃣ Login

```
Estudiante:
- Ir a http://localhost:3001/login
- Valida que el usuario tenga role: "student"
- Si intenta un profesor → Muestra error

Profesor:
- Ir a http://localhost:3001/loginTeacher
- Valida que el usuario tenga role: "teacher"
- Si intenta un estudiante → Muestra error
```

## 🛡️ Mensajes de Error

Cuando un usuario intenta acceder con rol incorrecto:

```
❌ Error: Eres teacher. Este login es solo para estudiantes. 
Por favor, usa el login correcto.
```

En el backend:
```json
{
  "error": "Solo estudiantes pueden acceder a esta función",
  "authenticated": true,
  "role": "teacher",
  "status": 403
}
```

## 📁 Archivos Modificados

### Backend
- `app/controllers/concerns/authorization.rb` - ✨ **NUEVO** - Módulo de autorización
- `app/controllers/application_controller.rb` - Incluye Authorization
- `app/controllers/users_controller.rb` - Retorna rol en login/register
- `app/controllers/pis_controller.rb` - Protege con authorize_student!
- `config/routes.rb` - Añade GET /login

### Frontend
- `pages/login.vue` - ✅ Valida role === "student"
- `pages/loginTeacher.vue` - ✅ Valida role === "teacher"
- `pages/register.client.vue` - ✅ Especifica role: "student"
- `pages/registerTeacher.vue` - ✨ **NUEVO** - Registro de profesores
- `composables/useAuthorization.ts` - ✨ **NUEVO** - Validación en componentes

## 🧪 Testing

### Test 1: Login de Estudiante
```bash
curl -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -d '{"username":"Student One","password":"password123"}'
```

**Respuesta esperada:**
```json
{
  "authenticated": true,
  "role": "student",
  "user": {
    "id": 78,
    "username": "Student One",
    "email": "student@school.com"
  }
}
```

### Test 2: Login de Profesor
```bash
curl -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -d '{"username":"ProfesorTest","password":"password123"}'
```

**Respuesta esperada:**
```json
{
  "authenticated": true,
  "role": "teacher",
  "user": {
    "id": 81,
    "username": "ProfesorTest",
    "email": "profesor@test.com"
  }
}
```

### Test 3: Registro de Profesor
```bash
curl -X POST http://localhost:3000/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "NewTeacher",
    "email": "newteacher@test.com",
    "password": "password123",
    "password_confirmation": "password123",
    "role": "teacher"
  }'
```

**Respuesta esperada:**
```json
{
  "id": 82,
  "username": "NewTeacher",
  "email": "newteacher@test.com",
  "role": "teacher",
  "message": "User registered successfully"
}
```

## 🔄 Jerarquía de Validación

```
┌─────────────────────────────────┐
│   Request a Ruta Protegida      │
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│ 1. ¿Existe sesión? (login)      │ ← authenticate_user!
└────────────┬────────────────────┘
             │ NO → 401 Unauthorized
             │
             ▼ SÍ
┌─────────────────────────────────┐
│ 2. ¿Rol correcto? (student)     │ ← authorize_student!
└────────────┬────────────────────┘
             │ NO → 403 Forbidden
             │
             ▼ SÍ
┌─────────────────────────────────┐
│ ✅ Acceso Permitido             │
└─────────────────────────────────┘
```

## 💡 Notas Importantes

1. **Las sesiones persisten** - Las cookies se guardan automáticamente
2. **Validación en ambos lados** - Frontend y backend validan el rol
3. **Seguro** - No se retornan contraseñas, se hashean con bcrypt
4. **Extensible** - Puedes agregar más roles simplemente
5. **Sin datos rotos** - Todo lo anterior sigue funcionando

## 🎓 Próximos Pasos

Ahora que tienes el sistema de autorización:

1. Protege más rutas en el backend con `authorize_teacher!` o `authorize_student!`
2. Crea vistas específicas en el frontend para cada rol
3. Agrega validación en componentes con `useAuthorization`
4. Implementa el flujo de visualización de estudiantes para profesores
5. Agrega más funcionalidades según necesites

---

**¿Preguntas?** Revisa [AUTORIZATION_SYSTEM.md](./AUTORIZATION_SYSTEM.md) para documentación completa.
