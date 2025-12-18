<template>
  <div>
    <div>
      <div>
        <div class="mb-6">
          <h1>Welcome</h1>
          <p>Greetings. Are you a teacher or student?</p>
          <select name="select" id="duh">
            <option value="el1">Teacher</option>
            <option value="el2">Student</option>
          </select>
        </div>

        <form class="space-y-4" @submit.prevent="onSubmit">
          <div>
            <label for="email">Email</label>
            <input
              id="email"
              v-model="form.email"
              type="email"
              autocomplete="email"
              placeholder="you@example.com"
              class="w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-slate-900 placeholder:text-slate-400 shadow-sm outline-none focus:ring-2 focus:ring-slate-900/10 focus:border-slate-300"
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
                class="w-full rounded-xl border border-slate-200 bg-white px-4 py-3 pr-12 text-slate-900 placeholder:text-slate-400 shadow-sm outline-none focus:ring-2 focus:ring-slate-900/10 focus:border-slate-300"
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
