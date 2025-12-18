<template>
  <div class="min-h-screen bg-[#333]">
    <header class="text-white sticky top-0 z-50">
      <nav class="max-w-5xl max-auto flex items-center justify-between px-4 py-3">
        <NuxtLink to="/" class="text-xl font-bold tracking-wide ">
          Gencat
        </NuxtLink>
        <div class="flex items-center gap-5 text-sm font-medium">
          <NuxtLink to="/" class="hover:text-blue-500 transition">Home</NuxtLink>
          <NuxtLink to="/sign" class="hover:text-blue-500 transition"><i class="fas fa-user"></i>Àrea privada</NuxtLink>
          <NuxtLink to="/register" class="hover:text-blue-500 tranisition">Register</NuxtLink>
          
        </div>
      </nav>
    </header>
    <main class="max-w-5xl mx-auto px-4 py-6">
      <slot />
    </main>
  </div>
</template>