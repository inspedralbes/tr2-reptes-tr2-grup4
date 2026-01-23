<script setup lang="ts">
const route = useRoute()
const router = useRouter()

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
  if (!studentId.value) return
  loading.value = true
  error.value = null
  summary.value = ""
  try {
    const res = await fetch(`http://localhost:3000/teacher/students/${studentId.value}/summary`, {
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

onMounted(async () => {
  if (studentId.value) {
    await fetchSummary()
  } else {
    error.value = "Missing studentId. Go back and select a student again."
  }
})
</script>