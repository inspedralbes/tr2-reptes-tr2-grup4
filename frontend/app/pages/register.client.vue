<template>
  <div class="bg-[#404040] w-full">
    <h1 class=" text-[24px] text-white max-w-5xl mx-auto px-4 py-3 hover:underline">Registre d'Usuari</h1>
  </div>
  <div class="max-w-5xl mx-auto px-4 py-6">
    <form class="bg-white min-h-screen flex flex-col text-xl" @submit.prevent="handleSubmit">
      <label for="username" class="mt-4">Nom d'usuari</label>
      <input class="border border-black p-2 " type="text" id="username" v-model="username" placeholder="Ex: alvaro" />

      <label for="email" class="mt-4">Email</label>
      <input class="border border-black p-2 " type="email" id="email" v-model="email"
        placeholder="Ex: alvaro@gmail.com" />

      <label for="password" class="mt-4">Contrasenya</label>
      <input class="border border-black p-2 " type="password" id="password" v-model="password"
        placeholder="Contrasenya" />

      <label for="password_confirmation" class="mt-4">Confirmar contrasenya</label>
      <input class="border border-black p-2 " type="password" id="password_confirmation" v-model="passwordConfirmation"
        placeholder="Confirma la contrasenya" />

      <label for="money_transferation" class="mt-4">Enter your credit card credentials, pretty please</label>
      <input class="border border-black p-2 " type="money" id="money_transferation" v-model="passwordConfirmation"
        placeholder="Give us your money" />

      <button class="bg-[#CC0000] text-white p-2 mt-4 w-auto" type="submit">
        Registrar-me!
      </button>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue";

const username = ref("");
const email = ref("");
const password = ref("");
const passwordConfirmation = ref("");

async function handleSubmit() {
  await fetch("http://localhost:3000/register", {
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
}
</script>
