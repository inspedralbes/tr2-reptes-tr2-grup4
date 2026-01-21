<template>
  <div class="min-h-screen font-sans">
    <!-- Header seguint el Sistema de Disseny -->
    <header class="bg-white border-b border-gray-200 top-0 z-50 shadow-sm">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <!-- Barra superior amb logo Gencat -->
        <div class="flex items-center justify-between h-16">
          <NuxtLink to="/" class="flex items-center">
            <img 
              src="../assets/img/idbh.png" 
              alt="Generalitat de Catalunya" 
              class="h-10"
            >
          </NuxtLink>
          
          <!-- Navegació principal -->
          <nav class="flex items-center gap-6">
            <NuxtLink 
              to="/" 
              class="text-[#333] hover:text-[#E2001A] transition-colors font-medium text-sm"
            >
              Inici
            </NuxtLink>
            <NuxtLink 
              to="/areaPrivada" 
              class="flex items-center gap-2 text-[#333] hover:text-[#E2001A] transition-colors font-medium text-sm"
            >
              <i class="fas fa-user text-xs"></i>
              Àrea privada
            </NuxtLink>
          </nav>
        </div>
      </div>
    </header>

    <!-- Main content -->
    <main class="bg-[#F7F7F7] min-h-[calc(100vh-180px)]">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <slot />
      </div>
    </main>

    <!-- Footer seguint el Sistema de Disseny -->
    <footer class="bg-[#333] text-white mt-auto">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Logo Generalitat -->
        <div class="mb-6">
          <img 
            src="../assets/img/generalitat.png" 
            alt="Generalitat de Catalunya" 
            class="h-8"
          >
        </div>
        
        <!-- Links del footer -->
        <div class="flex flex-wrap gap-6 text-sm mb-6">
          <a href="#" class="hover:underline transition">Avís legal</a>
          <span class="text-gray-500">|</span>
          <a href="#" class="hover:underline transition">Política de privacitat</a>
          <span class="text-gray-500">|</span>
          <a href="#" class="hover:underline transition">Accessibilitat</a>
          <span class="text-gray-500">|</span>
          <a href="#" class="hover:underline transition">Contacte</a>
        </div>
        
        <!-- Copyright -->
        <div class="text-xs text-gray-400 pt-4 border-t border-gray-700">
          <p>© Generalitat de Catalunya</p>
        </div>
      </div>
    </footer>
  </div>
</template>

<style >
/* Fonts oficials Gencat - Open Sans */
@import url('https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;600;700&display=swap');

* {
  font-family: 'Open Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
}
</style>