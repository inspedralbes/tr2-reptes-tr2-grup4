<script setup>
const router = useRouter();

function goToLogin() {
  router.push('/login');
}
</script>
<template>
  <h1 class="text-4xl ">Accés</h1>
  <p>Per accedir a l'Àrea privada cal que t'identifiquis amb un dels mecanismes d'identificació digital vàlids.</p>
  <button @click="goToLogin" class="bg-[#C00000] text-white p-[0.5em] rounded-sm hover:bg-[#C00000]/50 ">
    <i class="fas fa-lock"></i> Soc estudiant
  </button>
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
</template>