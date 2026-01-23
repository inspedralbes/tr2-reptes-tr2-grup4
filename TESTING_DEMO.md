# 🎬 Demo: Cómo Probar el Sistema de Autorización

## ✅ Prueba en el Navegador

### Escenario 1: Estudiante que intenta acceder como profesor

1. **Abre http://localhost:3001/loginTeacher**
2. **Intenta iniciar sesión con:**
   - Usuario: `Student One`
   - Contraseña: `password123`
3. **Resultado esperado:**
   ```
   ❌ Error: Eres student. Este login es solo para profesores. 
   Por favor, usa el login correcto.
   ```
4. **El sistema NO permite el acceso a /teacher** ✅

### Escenario 2: Profesor que intenta acceder como estudiante

1. **Abre http://localhost:3001/login**
2. **Intenta iniciar sesión con:**
   - Usuario: `ProfesorTest`
   - Contraseña: `password123`
3. **Resultado esperado:**
   ```
   ❌ Error: Eres teacher. Este login es solo para estudiantes. 
   Por favor, usa el login correcto.
   ```
4. **El sistema NO permite el acceso a /private** ✅

### Escenario 3: Estudiante accede correctamente

1. **Abre http://localhost:3001/login**
2. **Inicia sesión con:**
   - Usuario: `Student One`
   - Contraseña: `password123`
3. **Resultado esperado:**
   ```
   ¡Bienvenido, Student One!
   [Redirige a /private]
   ```
4. **Ve su PI** ✅

### Escenario 4: Profesor accede correctamente

1. **Abre http://localhost:3001/loginTeacher**
2. **Inicia sesión con:**
   - Usuario: `ProfesorTest`
   - Contraseña: `password123`
3. **Resultado esperado:**
   ```
   ¡Bienvenido, ProfesorTest!
   [Redirige a /teacher]
   ```
4. **Accede al área de profesor** ✅

### Escenario 5: Registro de Nuevo Estudiante

1. **Abre http://localhost:3001/register**
2. **Completa el formulario:**
   - Nom d'usuari: `AlumnoNuevo`
   - Email: `alumno@test.com`
   - Contrasenya: `password123`
   - Confirmar: `password123`
3. **Clica "Registrar-me com a Estudiante"**
4. **Resultado esperado:**
   ```
   ¡Bienvenido, AlumnoNuevo! Redirigiendo al área de estudiantes...
   [Redirige a /private]
   ```
5. **El nuevo estudiante se registra automáticamente como student** ✅

### Escenario 6: Registro de Nuevo Profesor

1. **Abre http://localhost:3001/loginTeacher**
2. **Clica "¿No tienes cuenta? ¡Regístrate como profesor!"**
3. **Es redirigido a http://localhost:3001/registerTeacher**
4. **Completa el formulario:**
   - Nom d'usuari: `ProfesorNuevo`
   - Email: `profesor@test.com`
   - Contrasenya: `password123`
   - Confirmar: `password123`
5. **Clica "Registrar-me com a Professor"**
6. **Resultado esperado:**
   ```
   ¡Bienvenido, ProfesorNuevo! Redirigiendo al área de profesores...
   [Redirige a /loginTeacher]
   ```
7. **El nuevo profesor se registra automáticamente como teacher** ✅

## 🔍 Detalles Técnicos

### Flujo de Autenticación en el Backend

1. **POST /login**
   - Busca al usuario por username
   - Verifica la contraseña
   - Guarda el user_id en session
   - **Retorna el rol**

2. **POST /register**
   - Crea nuevo usuario
   - **Asigna el rol específico** (student o teacher)
   - Guarda session automáticamente
   - Retorna datos del usuario

3. **GET /me**
   - Verifica si existe session[:user_id]
   - Retorna datos del usuario actual
   - Incluye el rol

### Flujo de Autorización en el Backend

1. **before_action :authenticate_user!**
   - Verifica si session[:user_id] existe
   - Si no → 401 Unauthorized

2. **before_action :authorize_student!**
   - Verifica si current_user.student?
   - Si no → 403 Forbidden

3. **before_action :authorize_teacher!**
   - Verifica si current_user.teacher?
   - Si no → 403 Forbidden

### Flujo en el Frontend

1. **Login en login.vue**
   ```typescript
   if (data.role === "student") {
     // ✅ Permite acceso a /private
     router.push("/private");
   } else {
     // ❌ Rechaza y muestra error
     message.value = "Error: Eres {role}...";
   }
   ```

2. **Login en loginTeacher.vue**
   ```typescript
   if (data.role === "teacher") {
     // ✅ Permite acceso a /teacher
     router.push("/teacher");
   } else {
     // ❌ Rechaza y muestra error
     message.value = "Error: Eres {role}...";
   }
   ```

## 📊 Matriz de Validación

```
                   INTENTA      TIENE         RESULTADO
                  ACCEDER A      ROLE
────────────────────────────────────────────────────────
Student           /login        student       ✅ Permite
Student           /loginTeacher student       ❌ Error
Student           /register     (n/a)         ✅ Crea student
Student           /registerTeacher (n/a)     ❌ Redirige a /loginTeacher

Teacher           /login        teacher       ❌ Error
Teacher           /loginTeacher teacher       ✅ Permite
Teacher           /register     (n/a)         ❌ Redirige a /login
Teacher           /registerTeacher (n/a)     ✅ Crea teacher

Student           /pis          student       ✅ Permite (authorize_student!)
Teacher           /pis          teacher       ❌ Error (authorize_student!)
```

## 🐛 Solución de Problemas

### "Credenciales inválidas"
- Verifica el usuario existe en la BD
- Verifica la contraseña es correcta
- Usuarios de prueba: `Student One`, `ProfesorTest`

### "Error: Este login es solo para estudiantes"
- Estás usando un usuario con role: teacher
- Ve a `/loginTeacher`

### "Error: Este login es solo para profesores"
- Estás usando un usuario con role: student
- Ve a `/login`

### La sesión no se mantiene (curl)
- Las cookies en curl no persisten entre comandos
- En el navegador funciona correctamente
- Para probar con curl usa el mismo comando con `-b` y `-c`

## 📝 Usuarios de Prueba Disponibles

| Username | Password | Role |
|----------|----------|------|
| Student One | password123 | student |
| ProfesorTest | password123 | teacher |

## 🚀 Crear Usuarios Nuevos

Desde el navegador:

1. **Estudiante:**
   - Ve a http://localhost:3001/register
   - Completa el formulario
   - role se asigna automáticamente como "student"

2. **Profesor:**
   - Ve a http://localhost:3001/registerTeacher
   - Completa el formulario
   - role se asigna automáticamente como "teacher"

---

**¡Listo para probar!** 🎉 Abre http://localhost:3001 en tu navegador.
