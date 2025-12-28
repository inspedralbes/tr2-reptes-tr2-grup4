<template>
  <h1 class="text-white text-3xl">Sign in page</h1>

  <form class="bg-white min-h-screen" @submit.prevent="handleSubmit">
    <label for="username">Nom d'usuari</label>
    <input class="border border-black" type="text" id="username" v-model="username" autocomplete="username" />

    <label for="password">Contrasenya</label>
    <input class="border border-black" type="password" id="password" v-model="password"
      autocomplete="current-password" />

    <button class="bg-gray-400 text-black p-2" type="submit">
      Entrar
    </button>

    <p v-if="message" class="mt-4 text-sm">
      {{ message }}
    </p>

    <pre v-if="debug" class="mt-2 text-xs whitespace-pre-wrap">
      {{ debug }}
    </pre>
  </form>
</template>

<script setup lang="ts">
import { ref } from "vue";

const username = ref("");
const password = ref("");
const message = ref("");
const debug = ref<any>(null);

async function handleSubmit() {
  message.value = "Signing in...";
  debug.value = null;

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

    const data = await res.json().catch(() => ({}));
    debug.value = { status: res.status, data };

  } catch (err: any) {
    message.value = `Failed to fetch: ${err?.message || "unknown error"}`;
    debug.value = err;
  }
}
</script>
