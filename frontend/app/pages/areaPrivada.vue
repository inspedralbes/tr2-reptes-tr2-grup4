<script setup>
const router = useRouter();

function goToLogin() {
  router.push('/login');
}

function goToLoginTeacher() {
  router.push('/loginTeacher');
}

function goToLoginAdmin() {
  router.push('/loginAdmin');
}


</script>
<template>
    <div class="bg-[#404040] w-full">
      <h1 class=" text-[24px] text-white max-w-5xl mx-auto px-4 py-3">Accés</h1>
    </div>
  <div class="max-w-5xl mx-auto px-6 py-10 min-h-screen bg-white">
    <p>Per accedir a l'Àrea privada cal que t'identifiquis amb un dels mecanismes d'identificació digital vàlids.</p>
    <button @click="goToLogin" class="bg-[#C00000] text-white p-[0.5em] rounded-sm hover:bg-[#C00000]/50 ">
      <i class="fas fa-lock"></i> Soc estudiant
    </button>
    <br> <br>
    <button @click="goToLoginTeacher" class="bg-[#C00000] text-white p-[0.5em] rounded-sm hover:bg-[#C00000]/50">
      <i class="fas fa-lock"></i> Soc professor
    </button>
    <br>
    <p>Què pots fer a la teva Àrea privada?</p>
    <ul>
      <li> <i class="fas fa-calendar-days"></i> Fer el seguiment dels teus tràmits i gestions, si ets intermediari, també
        els dels teus clients. </li>
      <li><i class="fas fa-bell"></i> Accedir a les notificacions electròniques.</li>
      <li> <i class="fas fa-circle-question"></i> Sol·licitar ajuda sobre les gestions amb l'Administració.</li>
      <li> <i class="fas fa-sliders"></i> Subscriure't a avisos, novetats i serveis personalitzats.</li>
      <li><i class="fa-regular fa-user"></i>Mantenir les teves dades actualitzades i, si ets una empresa o autònom/a,
        també les dels teus establiments.</li>
    </ul>
  </div>
</template>