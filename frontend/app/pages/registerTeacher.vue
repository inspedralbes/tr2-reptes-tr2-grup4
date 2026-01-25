<template>
  <div class="bg-[#404040] w-full">
    <h1
      class="text-[24px] text-white max-w-5xl mx-auto px-4 py-3 hover:underline"
    >
      Registre de Professor
    </h1>
  </div>
  <div class="max-w-5xl mx-auto px-4 py-6">
    <form
      class="bg-white min-h-screen flex flex-col text-xl"
      @submit.prevent="handleSubmit"
    >
      <label for="username" class="mt-4 font-semibold">Nom d'usuari</label>
      <input
        class="border border-black p-2"
        type="text"
        id="username"
        v-model="username"
        placeholder="Ex: professor_joan"
        required
      />

      <label for="email" class="mt-4 font-semibold">Email</label>
      <input
        class="border border-black p-2"
        type="email"
        id="email"
        v-model="email"
        placeholder="Ex: joan@escola.cat"
        required
      />

      <label for="password" class="mt-4 font-semibold">Contrasenya</label>
      <input
        class="border border-black p-2"
        type="password"
        id="password"
        v-model="password"
        placeholder="Contrasenya (mínim 6 caràcters)"
        required
      />

      <label for="password_confirmation" class="mt-4 font-semibold"
        >Confirmar contrasenya</label
      >
      <input
        class="border border-black p-2"
        type="password"
        id="password_confirmation"
        v-model="passwordConfirmation"
        placeholder="Confirma la contrasenya"
        required
      />

      <button
        class="bg-[#CC0000] text-white p-2 mt-6 w-auto font-semibold hover:bg-red-700"
        type="submit"
        :disabled="isLoading"
      >
        {{ isLoading ? "Registrant..." : "Registrar-me com a Professor" }}
      </button>

      <p v-if="successMessage" class="mt-4 text-green-600 font-semibold">
        {{ successMessage }}
      </p>

      <p v-if="errorMessage" class="mt-4 text-red-600 font-semibold">
        {{ errorMessage }}
      </p>

      <NuxtLink
        to="/login"
        class="bg-gray-400 text-black p-2 inline-block mt-4 text-center"
      >
        ¿Ya tienes cuenta? Inicia sesión
      </NuxtLink>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue";
import { useRouter } from "vue-router";

const router = useRouter();

const username = ref("");
const email = ref("");
const password = ref("");
const passwordConfirmation = ref("");
const errorMessage = ref("");
const successMessage = ref("");
const isLoading = ref(false);

async function handleSubmit() {
  errorMessage.value = "";
  successMessage.value = "";

  // Validar que las contraseñas coincidan
  if (password.value !== passwordConfirmation.value) {
    errorMessage.value = "Las contraseñas no coinciden";
    return;
  }

  // Validar longitud de contraseña
  if (password.value.length < 6) {
    errorMessage.value = "La contraseña debe tener al menos 6 carácteres";
    return;
  }

  isLoading.value = true;

  try {
    const res = await fetch("/api/register", {
      method: "POST",
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        username: username.value,
        email: email.value,
        password: password.value,
        password_confirmation: passwordConfirmation.value,
        role: "teacher", // Especificar que es profesor
      }),
    });

    const data = await res.json();

    if (res.ok) {
      successMessage.value = `¡Bienvenido, ${data.username}! Redirigiendo al área de profesores...`;
      setTimeout(() => {
        router.push("/loginTeacher");
      }, 2000);
    } else {
      errorMessage.value =
        data.error || data.errors?.email?.[0] || "Error al registrarse";
    }
  } catch (error) {
    console.error("Error:", error);
    errorMessage.value = "Error de conexión. Por favor, intenta de nuevo.";
  } finally {
    isLoading.value = false;
  }
}
</script>
