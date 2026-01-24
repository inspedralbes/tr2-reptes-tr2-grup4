<template>
  <div class="bg-[#404040] w-full">
    <h1 class="text-[24px] text-white max-w-5xl mx-auto px-4 py-3">
      Inici de Sessió - Estudiants
    </h1>
  </div>
  <div class="max-w-5xl mx-auto px-4 py-6">
    <form
      class="bg-white min-h-screen flex flex-col"
      @submit.prevent="handleSubmit"
    >
      <label for="username" class="font-semibold">Nom d'usuari</label>
      <input
        class="border border-black p-2"
        type="text"
        id="username"
        v-model="username"
        autocomplete="username"
        required
      />

      <label for="password" class="mt-4 font-semibold">Contrasenya</label>
      <input
        class="border border-black p-2"
        type="password"
        id="password"
        v-model="password"
        autocomplete="current-password"
        required
      />

      <button
        class="bg-gray-400 text-black p-2 mt-4 font-semibold hover:bg-gray-500"
        type="submit"
        :disabled="isLoading"
      >
        {{ isLoading ? "Entrant..." : "Entrar" }}
      </button>

      <NuxtLink
        to="/register"
        class="bg-pink-400 text-black p-2 inline-block mt-4 text-center"
      >
        ¿No tienes cuenta? ¡Regístrate como estudiante!
      </NuxtLink>

      <div
        v-if="message"
        class="mt-4 p-2 rounded"
        :class="
          errorMessage ? 'bg-red-100 text-red-700' : 'bg-blue-100 text-blue-700'
        "
      >
        <p class="font-semibold">{{ message }}</p>
      </div>

      <pre
        v-if="debug"
        class="mt-2 text-xs whitespace-pre-wrap bg-gray-100 p-2 rounded"
      >
        {{ debug }}
      </pre>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue";

const username = ref("");
const password = ref("");
const message = ref("");
const errorMessage = ref(false);
const debug = ref<any>(null);
const isLoading = ref(false);
const router = useRouter();

async function handleSubmit() {
  message.value = "Validando credenciales...";
  errorMessage.value = false;
  debug.value = null;
  isLoading.value = true;

  try {
    const res = await fetch("http://localhost:3000/login", {
      method: "POST",
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        username: username.value,
        password: password.value,
      }),
    });

    const data = await res.json();
    debug.value = { status: res.status, data };

    if (res.ok && data.authenticated) {
      // Validar que el usuario sea estudiante
      if (data.role === "student") {
        message.value = `¡Bienvenido, ${data.user?.username}!`;
        setTimeout(() => {
          router.push("/private");
        }, 500);
      } else {
        errorMessage.value = true;
        message.value = `❌ Error: Eres ${data.role}. Este login es solo para estudiantes. Por favor, usa el login correcto.`;
      }
    } else {
      errorMessage.value = true;
      message.value = data.error || "Credenciales inválidas";
    }
  } catch (err: any) {
    errorMessage.value = true;
    message.value = `Error de conexión: ${err?.message || "unknown error"}`;
    debug.value = err;
  } finally {
    isLoading.value = false;
  }
}
</script>
