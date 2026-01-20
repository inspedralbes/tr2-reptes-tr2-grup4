<template>
  <div class="bg-[#404040] w-full">
    <h1 class=" text-[24px] text-white max-w-5xl mx-auto px-4 py-3">Inici de Sessió</h1>
  </div>
  <div class="max-w-5xl mx-auto px-4 py-6">
    <form class="bg-white min-h-screen flex flex-col" @submit.prevent="handleSubmit">
      <label for="username">Nom d'usuari</label>
      <input class="border border-black" type="text" id="username" v-model="username" autocomplete="username" />

      <label for="password">Contrasenya</label>
      <input class="border border-black" type="password" id="password" v-model="password"
        autocomplete="current-password" />

      <button class="bg-gray-400 text-black p-2" type="submit">Entrar</button>

      <NuxtLink to="/register" class="bg-pink-400 text-black p-2 inline-block">
        No accaunt? We have a proposition for you, create an account for a special price, just 14.99€, before IVA!
      </NuxtLink>

      <p v-if="message" class="mt-4 text-sm">
        {{ message }}
      </p>

      <pre v-if="debug" class="mt-2 text-xs whitespace-pre-wrap">
        {{ debug }}
      </pre>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue";

const { username } = useUser()
const password = ref("");
const message = ref("");
const debug = ref<any>(null);
const router = useRouter()


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
    router.push("/teacher");
    debug.value = { status: res.status, data };

  } catch (err: any) {
    message.value = `Failed to fetch: ${err?.message || "unknown error"}`;
    debug.value = err;
  }

}
</script>