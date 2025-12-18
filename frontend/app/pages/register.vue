<template>
  <h1 class="text-white text-3xl">Register page</h1>

  <form class="bg-white min-h-screen" @submit.prevent="handleSubmit">
    <label for="username">Nom d'usuari</label>
    <input class="border border-black" type="text" id="username" v-model="username" />

    <label for="email">Email</label>
    <input class="border border-black" type="email" id="email" v-model="email" />

    <label for="password">Contrasenya</label>
    <input class="border border-black" type="password" id="password" v-model="password" />

    <label for="password_confirmation">Confirmar contrasenya</label>
    <input class="border border-black" type="password" id="password_confirmation" v-model="passwordConfirmation" />

    <button class="bg-gray-400 text-black p-2" type="submit">
      Registrar-me!
    </button>
  </form>
</template>

<script setup lang="ts">
import { ref } from "vue";

const username = ref("");
const email = ref("");
const password = ref("");
const passwordConfirmation = ref("");

async function handleSubmit() {
  const res = await fetch("http://localhost:3000/register", {
    method: "POST",
    credentials: "include", // REQUIRED for sessions
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      username: username.value,
      email: email.value,
      password: password.value,
      password_confirmation: passwordConfirmation.value,
    }),
  });

  const data = await res.json();
  console.log(data);
}
</script>
