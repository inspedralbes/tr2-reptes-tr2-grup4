<template>
  <div class="max-w-3xl mx-auto px-4 py-6 min-h-screen bg-[#F7F7F7]">
    <div class="border bg-white p-4 flex items-start justify-between gap-4">
      <div>
        <h1 class="text-xl font-semibold">Document Summary</h1>
        <p class="text-sm text-gray-600 mt-1">
          Student ID: <span class="font-medium">{{ studentId ?? "—" }}</span>
        </p>
      </div>

      <button class="px-3 py-2 rounded border bg-white text-sm hover:bg-gray-50" @click="router.back()">
        Back
      </button>
    </div>

    <div class="mt-4 border bg-white p-4">
      <div class="flex items-center justify-between gap-3">
        <p class="font-semibold">AI Summary</p>

        <button
          class="px-3 py-2 rounded bg-black text-white text-sm disabled:opacity-40 disabled:cursor-not-allowed"
          :disabled="!studentId || loading"
          @click="fetchSummary"
        >
          {{ loading ? "Summarizing…" : "Run summary" }}
        </button>
      </div>

      <p v-if="error" class="text-sm text-red-600 mt-3">{{ error }}</p>

      <div v-if="summary" class="mt-3 whitespace-pre-wrap text-gray-800">
        {{ summary }}
      </div>

      <div v-else-if="!loading" class="mt-3 text-sm text-gray-500">
        Click “Run summary” to generate a summary of the full document.
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const route = useRoute()
const router = useRouter()
const config = useRuntimeConfig()

const studentId = computed(() => {
  const raw = route.query.studentId
  const s = Array.isArray(raw) ? raw[0] : raw
  if (!s) return null
  const n = Number(s)
  return Number.isFinite(n) ? n : null
})

const loading = ref(false)
const summary = ref("")
const error = ref<string | null>(null)

async function fetchSummary() {
  if (!studentId.value) {
    error.value = "Missing studentId in URL."
    return
  }
  loading.value = true
  error.value = null
  summary.value = ""
  try {
    const res = await fetch(`${config.public.apiBase}/teacher/students/${studentId.value}/summary`, {
      credentials: "include",
    })
    if (!res.ok) {
      const body = await res.text().catch(() => "")
      throw new Error(`Summary failed (${res.status}) ${body}`)
    }
    const data = await res.json()
    summary.value = String(data.summary ?? "")
    if (!summary.value.trim()) summary.value = "(Empty summary returned.)"
  } catch (e: any) {
    error.value = e?.message ?? "Failed to summarize."
    console.error(e)
  } finally {
    loading.value = false
  }
}

// Auto-run so the page is never “empty”
onMounted(() => {
  if (studentId.value) fetchSummary()
})
</script>
