<template>
  <div class="max-w-3xl mx-auto px-4 py-6 min-h-screen bg-[#F7F7F7]">
    <div class="border bg-white p-4 flex items-start justify-between gap-4">
      <div>
        <h1 class="text-xl font-semibold">Document Summary</h1>
        <p class="text-sm text-gray-600 mt-1">
          Student ID:
          <span class="font-medium">{{ studentId ?? "—" }}</span>
        </p>
      </div>

      <button
        type="button"
        class="px-3 py-2 rounded border bg-white text-sm hover:bg-gray-50"
        @click="router.back()"
      >
        Back
      </button>
    </div>

    <div class="mt-4 space-y-4">
      <div class="border bg-white p-4">
        <p class="text-sm text-gray-600">Source document</p>

        <div v-if="loadingDoc" class="text-sm text-gray-500 mt-2">Loading document…</div>
        <div v-else-if="docError" class="text-sm text-red-600 mt-2">{{ docError }}</div>

        <div v-else class="text-sm text-gray-700 mt-2 whitespace-pre-wrap">
          {{ combinedTextPreview }}
        </div>
      </div>

      <div class="border bg-white p-4">
        <div class="flex items-center justify-between gap-3">
          <p class="font-semibold">AI Summary</p>

          <button
            type="button"
            class="px-3 py-2 rounded bg-black text-white text-sm disabled:opacity-40 disabled:cursor-not-allowed"
            :disabled="loadingSummary || loadingDoc || !!docError || combinedText.length === 0"
            @click="summarize()"
          >
            {{ loadingSummary ? "Summarizing…" : "Run summary" }}
          </button>
        </div>

        <div v-if="summaryError" class="text-sm text-red-600 mt-3">
          {{ summaryError }}
        </div>

        <div v-if="summary" class="mt-3 whitespace-pre-wrap text-gray-800">
          {{ summary }}
        </div>

        <div v-else class="mt-3 text-sm text-gray-500">
          Click “Run summary” to generate a summary of the full document.
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
type DocSection = { id: string; title: string; content: string }

const route = useRoute()
const router = useRouter()

const studentId = computed(() => {
  const raw = route.query.studentId
  const s = Array.isArray(raw) ? raw[0] : raw
  if (!s) return null
  const n = Number(s)
  return Number.isFinite(n) ? n : null
})

const sections = ref<DocSection[]>([])
const loadingDoc = ref(false)
const docError = ref<string | null>(null)

const loadingSummary = ref(false)
const summary = ref<string>("")
const summaryError = ref<string | null>(null)

const combinedText = computed(() => {
  // Join sections into one “document”
  return sections.value
    .map(s => `${s.title}\n${s.content}`.trim())
    .filter(Boolean)
    .join("\n\n")
})

const combinedTextPreview = computed(() => {
  // Just a small preview so page isn't huge
  const t = combinedText.value
  if (t.length <= 900) return t
  return t.slice(0, 900) + "\n…"
})

async function fetchStudentDoc(id: number) {
  loadingDoc.value = true
  docError.value = null
  try {
    const res = await fetch(`http://localhost:3000/teacher/students/${id}/document`, {
      credentials: "include",
    })
    if (!res.ok) throw new Error(`Document fetch failed (${res.status})`)
    const data = await res.json()
    sections.value = (data.sections ?? []) as DocSection[]
  } catch (e: any) {
    sections.value = []
    docError.value = e?.message ?? "Failed to load document."
    console.error(e)
  } finally {
    loadingDoc.value = false
  }
}

// AI summarize, ninjas, we need to replace it here with our actual AI endpoint
async function summarize() {
  summary.value = ""
  summaryError.value = null
  loadingSummary.value = true
  try {
    const res = await fetch("http://localhost:3000/ai/summarize", {
      method: "POST",
      credentials: "include",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        text: combinedText.value,
        // optional knobs:
        // max_words: 200,
        // style: "teacher",
      }),
    })

    if (!res.ok) throw new Error(`Summarize failed (${res.status})`)
    const data = await res.json()

    // Expecting: { summary: "..." }
    summary.value = String(data.summary ?? "")
    if (!summary.value.trim()) summary.value = "(Empty summary returned.)"
  } catch (e: any) {
    summaryError.value = e?.message ?? "Failed to summarize."
    console.error(e)
  } finally {
    loadingSummary.value = false
  }
}

onMounted(async () => {
  if (!studentId.value) {
    docError.value = "Missing studentId in URL."
    return
  }
  await fetchStudentDoc(studentId.value)

  // Optional: auto-run summary immediately after loading doc:
  // if (!docError.value && combinedText.value.length) await summarize()
})
</script>
