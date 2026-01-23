<template>
  <div class="min-h-screen font-sans">
    <header class="bg-white border-b border-gray-200 top-0 z-50 shadow-sm">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-28">
          <NuxtLink to="/" class="flex items-center">
            <img 
              src="../assets/img/idbh.png" 
              alt="Generalitat de Catalunya" 
              class="h-10"
            >
            <span class="bg-[#ddd] h-6 mx-4 w-px"></span>
            <p class="text-xl text-[#333]">
              Ciutadania
            </p>
          </NuxtLink>
          
          <nav class="flex items-center gap-6">
            <!-- <NuxtLink 
              to="/" 
              class="hover:text-[#333] text-[#C00000] transition-colors font-medium text-sm hover:underline"
            >
              Inici
            </NuxtLink> -->
            <NuxtLink
              to="/areaPrivada"
              class="group flex items-center gap-2 font-semibold text-base border rounded-lg p-3
                    border-[#C00000] hover:border-[#333] transition-colors"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                viewBox="0 0 16 16"
                class="w-5 h-5 fill-[#D90000] group-hover:fill-[#333] transition-colors"
              >
                <path d="M8 8a3 3 0 1 0 0-6 3 3 0 0 0 0 6m2-3a2 2 0 1 1-4 0 2 2 0 0 1 4 0m4 8c0 1-1 1-1 1H3s-1 0-1-1 1-4 6-4 6 3 6 4m-1-.004c-.001-.246-.154-.986-.832-1.664C11.516 10.68 10.289 10 8 10s-3.516.68-4.168 1.332c-.678.678-.83 1.418-.832 1.664z"/>
              </svg>

              <span class="text-[#C00000] group-hover:text-[#333] transition-colors">
                Àrea privada
              </span>
            </NuxtLink>
          </nav>
        </div>
      </div>
    </header>
    <main class="bg-[#F7F7F7] min-h-[calc(100vh-180px)]">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <article> 
          <div class="min-h-screen bg-white px-6 max-w-5xl mx-auto py-10">
            <h1 class="text-4xl text-[#333] font-bold text-center p-4">SPECIALZ</h1>
            <p class="text-[#666] text-base text-justify">
              SPECIALZ és un servei orientat a facilitar la mobilitat educativa de l’alumnat amb necessitats educatives especials.
              Permet gestionar el trasllat d’un centre educatiu a un altre, assegurant que el nou centre disposi de la informació
              necessària per garantir una atenció adequada, continuada i respectuosa amb les necessitats de cada alumne.
              El servei posa especial atenció a la protecció de dades personals i al respecte de la privacitat, d’acord amb la normativa vigent.
            </p>

            <section class="mt-8">
              <h2 class="text-xl font-semibold text-[#333] mb-2">
                Què ofereix el servei
              </h2>
              <ul class="list-disc list-inside text-[#666] space-y-1">
                <li>Centralització de la informació educativa rellevant.</li>
                <li>Continuïtat en l’atenció educativa.</li>
                <li>Garantia de confidencialitat i protecció de dades.</li>
                <li>Suport als centres educatius en el procés d’acollida.</li>
              </ul>
            </section>
          </div>
        </article>
      </div>
    </main>
    <footer class="bg-[#333] text-white mt-auto">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="mb-6">
          <img 
            src="../assets/img/generalitat.png" 
            alt="Generalitat de Catalunya" 
            class="h-8"
          >
        </div>
        <div class="flex flex-wrap gap-6 text-sm mb-6">
          <a href="#" class="hover:underline transition">Avís legal</a>
          <span class="text-gray-500">|</span>
          <a href="#" class="hover:underline transition">Política de privacitat</a>
          <span class="text-gray-500">|</span>
          <a href="#" class="hover:underline transition">Accessibilitat</a>
          <span class="text-gray-500">|</span>
          <a href="#" class="hover:underline transition">Contacte</a>
        </div>
        <div class="text-xs text-gray-400 pt-4 border-t border-gray-700">
          <p>© Generalitat de Catalunya</p>
        </div>
      </div>
    </footer>
  </div>
</template>

<style>
@import url('https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;600;700&display=swap');

* {
  font-family: 'Open Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
}
</style>

<script setup>
definePageMeta({
  layout: false
})
</script>

