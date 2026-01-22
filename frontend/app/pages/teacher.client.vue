<template>
  <div class="max-w-5xl mx-auto px-4 py-6 min-h-screen bg-[#F7F7F7]">
    <div class="flex gap-4">
      <!-- Sidebar -->
      <aside class="w-56 shrink-0 space-y-3">
        <!-- Students list -->
        <div class="sticky top-24 max-h-[calc(100vh-6rem)] overflow-auto border bg-white p-3">
          <p class="font-semibold mb-2">Your Students</p>

          <button
            v-for="st in students"
            :key="st.id"
            type="button"
            class="block w-full text-left px-2 py-1 rounded hover:bg-gray-100"
            :class="selectedStudentId === st.id ? 'bg-gray-100 font-semibold' : ''"
            @click="selectStudent(st.id)"
          >
            {{ st.username }}
          </button>

          <p v-if="students.length === 0 && !loadingStudents" class="text-sm text-gray-500">
            No students yet.
          </p>
          <p v-if="loadingStudents" class="text-sm text-gray-500">Loading…</p>
        </div>

        <!-- Sections quick scroll -->
        <div class="sticky top-[22rem] max-h-[calc(100vh-22rem)] overflow-auto border bg-white p-3">
          <p class="font-semibold mb-2">Sections</p>

          <button
            v-for="sec in docVM.sections"
            :key="sec.id"
            type="button"
            class="block w-full text-left px-2 py-1 rounded hover:bg-gray-100"
            @click="scrollTo(sec.id)"
          >
            {{ sec.title }}
          </button>

          <p v-if="!docVM.sections.length && selectedStudentId && !loadingDoc" class="text-sm text-gray-500">
            No sections for this student.
          </p>
          <p v-if="loadingDoc" class="text-sm text-gray-500">Loading document…</p>
        </div>
      </aside>

      <!-- Main document -->
      <main class="flex-1">
        <div class="border bg-white p-4">
          <h1 class="text-xl font-semibold">Teacher Area</h1>
          <p class="text-sm text-gray-600 mt-1">
            Selected student:
            <span class="font-medium">
              {{ selectedStudentName ?? '—' }}
            </span>
          </p>
        </div>

        <button
            type="button"
            class="px-3 py-2 rounded bg-black text-white text-sm disabled:opacity-40 disabled:cursor-not-allowed"
            :disabled="!selectedStudentId || loadingDoc || !!docError || docVM.sections.length === 0"
            @click="goToSummary()"
            title="Summarize this student's whole document"
          >
            Summarize
        </button>

        <div class="mt-4 space-y-4">
          <section
            v-for="sec in docVM.sections"
            :key="sec.id"
            :id="`sec-${sec.id}`"
            class="border bg-white p-4 scroll-mt-28"
          >
            <h2 class="text-lg font-semibold">{{ sec.title }}</h2>
            <p class="mt-2 text-gray-800 whitespace-pre-wrap">
              {{ sec.content }}
            </p>
          </section>

          <div v-if="!selectedStudentId" class="border bg-white p-6 text-gray-600">
            Pick a student from the left to load their document.
          </div>

          <div v-if="docError" class="border bg-white p-6 text-red-600">
            {{ docError }}
          </div>
        </div>
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
type Student = { id: number; username: string; email?: string }
type DocSection = { id: string; title: string; content: string }

const router = useRouter()

const docVM = reactive<{ sections: DocSection[] }>({ sections: [] })

const students = ref<Student[]>([])
const selectedStudentId = ref<number | null>(null)
const loadingStudents = ref(false)
const loadingDoc = ref(false)
const docError = ref<string | null>(null)

const selectedStudentName = computed(() => {
  if (!selectedStudentId.value) return null
  return students.value.find(s => s.id === selectedStudentId.value)?.username ?? null
})

function scrollTo(sectionId: string) {
  const el = document.getElementById(`sec-${sectionId}`)
  if (!el) return
  el.scrollIntoView({ behavior: "smooth", block: "start" })
}

function goToSummary() {
  if (!selectedStudentId.value) return
  router.push({
    path: "/teacher/summary",
    query: { studentId: String(selectedStudentId.value) },
  })
}

async function fetchStudents() {
  loadingStudents.value = true
  try {
    // /teacher/students endpoint duh
    const res = await fetch("http://localhost:3000/teacher/students", {
      method: "GET",
      credentials: "include",
    })
    if (!res.ok) throw new Error(`Students fetch failed (${res.status})`)
    const data = (await res.json()) as Student[]
    students.value = data

    // this sh auto select first student
    const firstStudent = students.value[0]
    if (firstStudent) {
      await selectStudent(firstStudent.id)
    }
  } catch (e: any) {
    students.value = []
    console.error(e)
  } finally {
    loadingStudents.value = false
  }
}

async function fetchStudentDoc(studentId: number) {
  loadingDoc.value = true
  docError.value = null
  try {
    // /teacher/students/:id/document
    const res = await fetch(`http://localhost:3000/teacher/students/${studentId}/document`, {
      credentials: "include",
    })
    if (!res.ok) throw new Error(`Document fetch failed (${res.status})`)

    // Expecting: { sections: [{ id, title, content }, ...] }
    const data = await res.json()
    docVM.sections = (data.sections ?? []) as DocSection[]
  } catch (e: any) {
    docVM.sections = []
    docError.value = e?.message ?? "Failed to load document."
    console.error(e)
  } finally {
    loadingDoc.value = false
  }
}

async function selectStudent(studentId: number) {
  if (selectedStudentId.value === studentId) return
  selectedStudentId.value = studentId
  await fetchStudentDoc(studentId)
}

onMounted(async () => {
  await fetchStudents()
})
</script>
