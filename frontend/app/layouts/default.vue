<template>
  <div class="min-h-screen font-[Open Sans Regular]">
    <header class="text-white sticky top-0 z-50  bg-[#333]">
      <nav class="max-w-5xl mx-auto flex items-center justify-between px-4 py-3">
        <NuxtLink to="/" class="text-xl">
          <img src="../assets/img/gencat.svg" alt="Logotip Gencat" class="h-6">
        </NuxtLink>
        <div class="flex items-center gap-5 text-sm font-medium">
          <NuxtLink to="/" class="hover:underline transition">Home</NuxtLink>
          <NuxtLink to="/areaPrivada" class="hover:underline transition"><i class="fas fa-user"></i>   Accés a l'àrea privada</NuxtLink>
        </div>
      </nav>
    </header>
    <main class="mx-auto">
      <slot />
    </main>
    <footer>
      <div class="bg-[#333] text-white mt-10">
        <div class="max-w-5xl mx-auto px-4 py-2 text-sm flex items-center justify-between">
          <img src="../assets/img/generalitat.png" alt="Logotip Generalitat de Catalunya" class="h-7">
          <p>Avís legal | Política de privacitat | Accessibilitat</p>
        </div>
      </div>
    </footer>
  </div>
</template>