<template>
  <div class="min-h-screen bg-[#f5f5f5] text-[#333]">

    <!-- HEADER -->
    <header class="bg-white border-b border-gray-300">
      <div class="max-w-7xl mx-auto px-6 py-4 flex items-center">
        <h1 class="text-xl font-semibold">
          Administració · Pla de Suport Individualitzat
        </h1>
      </div>
    </header>

    <div class="flex max-w-7xl mx-auto">

      <!-- SIDEBAR -->
      <aside class="w-64 bg-white border-r border-gray-300 min-h-[calc(100vh-72px)]">
        <nav class="px-4 py-6 space-y-2 text-sm">
          <a class="block px-3 py-2 rounded hover:bg-gray-100 font-medium">
            Tauler principal
          </a>
          <a class="block px-3 py-2 rounded hover:bg-gray-100">
            Usuaris
          </a>
          <a class="block px-3 py-2 rounded hover:bg-gray-100">
            Plans de suport
          </a>
          <a class="block px-3 py-2 rounded hover:bg-gray-100">
            Documents
          </a>
          <a class="block px-3 py-2 rounded hover:bg-gray-100">
            Configuració
          </a>
        </nav>
      </aside>

      <!-- MAIN CONTENT -->
      <main class="flex-1 px-8 py-8">

        <!-- PAGE TITLE -->
        <section class="mb-6">
          <h2 class="text-2xl font-semibold mb-2">
            Gestió del Pla de Suport Individualitzat
          </h2>
          <p class="text-gray-700 max-w-3xl">
            Des d’aquest espai podeu consultar, editar i gestionar la informació
            associada als plans de suport individualitzat dels usuaris.
          </p>
        </section>

        <!-- CONTENT BLOCK -->
        <section class="bg-white border border-gray-300 p-6">
          <h3 class="text-lg font-semibold mb-4">
            Accions disponibles
          </h3>

          <ul class="list-disc pl-6 space-y-2 text-sm">
            <li>Consultar dades del pla</li>
            <li>Editar informació registrada</li>
            <li>Descarregar el document en format PDF</li>
            <li>Actualitzar continguts del pla</li>
          </ul>
        </section>

      </main>
    </div>
  </div>
</template>
