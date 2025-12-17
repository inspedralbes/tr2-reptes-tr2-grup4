<script setup>
  const router = useRouter();

  function goToRegister() {
    router.push("/register");
  }

  function goToLogin() {
    router.push("/sign");
  }
</script>

<template>
  <article>
    <div class="container">
      <h1 class="title">SPECIALZ</h1>
      <p class="text">This is a service to help students with special needs(intellectually disabled) to help them move from one studying facility to another and provide the new institut/school/uni with all the existing information in regards to this student and how to work with it(so he annoys everyone around less and maybe even learn something). Our service treat students privacy with utmost concern and respect and was created out of pure kindness and compassion to help less usefull parts of society integrated in new environment easier and be treated almost as normal functional humans.</p>
    </div>
    <button @click="goToRegister">
      Register
    </button>
    <button @click="goToLogin">
      Sign
    </button>    
  </article>


</template>
