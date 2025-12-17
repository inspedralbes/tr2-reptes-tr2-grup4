<template>
  <div>
    <div>
      <div>
        <div class="mb-6">
          <h1 class = "text-2xl font-bold text-blue">Welcome back</h1>
          <p>Sign in to continue.</p>
        </div>

        <form class="space-y-4" @submit.prevent="onSubmit">
          <div>
            <label for="email">Username</label>
            <input
              id="user"
              v-model="form.email"
              type="user"
              autocomplete="user"
              placeholder="niggauser"
            />
          </div>

          <div>
            <label for="password">Password</label>
            <div class="relative">
              <input
                id="password"
                v-model="form.password"
                :type="showPassword ? 'text' : 'password'"
                autocomplete="current-password"
                placeholder="••••••••"
              />
              <button
                type="button"
                class="absolute inset-y-0 right-2 my-2 px-3 rounded-lg text-sm text-slate-600 hover:text-slate-900 hover:bg-slate-100"
                @click="showPassword = !showPassword"
              >
                {{ showPassword ? 'Hide' : 'Show' }}
              </button>
            </div>
          </div>

          <div>
            <label>
              <input
                v-model="form.remember"
                type="checkbox"
                class="h-4 w-4 rounded border-slate-300 text-slate-900 focus:ring-slate-900/20"
              />
              Remember me
            </label>

            <NuxtLink
              to="/forgot-password"
            >
              Forgot password?
            </NuxtLink>
          </div>

          <button
            type="submit"
          >
            Sign in
          </button>

          <div>
            <div>
              <span>OR</span>
            </div>
          </div>
        </form>

        <p>
          Don’t have an account?
          <NuxtLink to="/register">
            Create one
          </NuxtLink>
        </p>

        <p v-if="uiMessage">
          {{ uiMessage }}
        </p>
      </div>

      <p>
        © {{ new Date().getFullYear() }} Your App
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: 'default',
})

const form = reactive({
  email: '',
  password: '',
  remember: true,
})

const showPassword = ref(false)
const uiMessage = ref('')

function onSubmit() {
  uiMessage.value = `Attempting login for ${form.email || '(no email entered)'}…`
}

function onGoogle() {
  uiMessage.value = 'Google sign-in clicked (visual only).'
}
</script>