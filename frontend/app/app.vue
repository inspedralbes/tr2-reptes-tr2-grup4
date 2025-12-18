<script setup>
  useHead({
    link: [
      {
        rel: "stylesheet",
        href: "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css",
      },
    ],
  });
</script>
<template>
  <div>
    <h1 class="text-cyan-500">Nuxt</h1>
    <NuxtRouteAnnouncer />
    <NuxtWelcome />
  </div>
</template>
