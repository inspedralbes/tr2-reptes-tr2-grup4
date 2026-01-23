<template>
  <div class="max-w-5xl mx-auto px-4 py-6 min-h-screen bg-[#F7F7F7]">
    <div class="flex gap-4">
      <!-- Sidebar (class="w-56 shrink-0 space-y-3")-->
      <aside class="w-56 shrink-0 space-y-3">
        <!-- Students list -->
        <div class="sticky top-24 space-y-3">
        <div class="max-h-[calc(100vh-6rem)] overflow-auto border bg-white p-3">
          <p class="font-semibold mb-2">Your Students</p>

          <button
            v-for="st in students"
            :key="st.id"
            type="button"
            class="block w-full text-left px-2 py-1 hover:bg-gray-100"
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
        <div class="max-h-[40vh] overflow-auto border bg-white p-3">
          <p class="font-semibold mb-2">Sections</p>

          <button
            v-for="sec in docVM.sections"
            :key="sec.id"
            type="button"
            class="block w-full text-left px-2 py-1 hover:bg-gray-100"
            @click="scrollTo(sec.id)"
          >
            {{ sec.title }}
          </button>

          <p v-if="!docVM.sections.length && selectedStudentId && !loadingDoc" class="text-sm text-gray-500">
            No sections for this student.
          </p>
          <p v-if="loadingDoc" class="text-sm text-gray-500">Loading document…</p>
        </div>

        <!-- Actions (buttons) -->
        <div class="border bg-white p-3">
          <p class="font-semibold mb-2">Actions</p>

          <div class="space-y-2">
            <button
              class="w-full px-4 py-2 bg-red-700 text-white disabled:opacity-40 disabled:cursor-not-allowed"
              type="button"
              :disabled="!selectedStudentId"
              @click="openUpload = true"
            >
              Upload document
            </button>

            <button
              class="w-full px-4 py-2 bg-red-700 text-white disabled:opacity-40 disabled:cursor-not-allowed"
              type="button"
              :disabled="!selectedStudentId"
              @click="openDownload = true"
            >
              Download document
            </button>

            <button
              class="w-full px-4 py-2 bg-red-700 text-white disabled:opacity-40 disabled:cursor-not-allowed"
              type="button"
              :disabled="!selectedStudentId || loadingDoc || !!docError || docVM.sections.length === 0"
              @click="goToSummary"
            >
              Summarize
            </button>
          </div>
        </div>
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

        <div class="mt-4 space-y-4">
          <section
            v-for="sec in docVM.sections"
            :key="sec.id"
            :id="`sec-${sec.id}`"
            class="border bg-white p-4 scroll-mt-28"
          >
            <div class="flex items-start justify-between gap-3">
              <h2 class="text-lg font-semibold">{{ sec.title }}</h2>

              <!-- Edit controls -->
              <div class="flex gap-2 shrink-0">
                <button
                  v-if="editingId !== sec.id"
                  class="border px-3 py-1"
                  type="button"
                  :disabled="!selectedStudentId"
                  @click="startEdit(sec)"
                >
                  Edit
                </button>

                <div v-else class="flex gap-2">
                  <button
                    class="border px-3 py-1"
                    type="button"
                    :disabled="saving"
                    @click="saveSection(sec)"
                  >
                    Save
                  </button>
                  <button
                    class="border px-3 py-1"
                    type="button"
                    :disabled="saving"
                    @click="cancelEdit(sec)"
                  >
                    Cancel
                  </button>
                </div>
              </div>
            </div>

            <p v-if="editingId !== sec.id" class="mt-2 text-gray-800 whitespace-pre-wrap">
              {{ sec.content }}
            </p>

            <div v-else class="mt-3">
              <textarea class="w-full border p-2 min-h-[140px]" v-model="drafts[sec.id]" />
              <p v-if="saveError" class="text-red-600 mt-2">{{ saveError }}</p>
            </div>
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

    <!-- Upload Modal -->
    <div v-if="openUpload" class="fixed inset-0 grid place-items-center bg-black/50 p-4 z-50" @click.self="openUpload = false">
      <form class="w-full max-w-sm bg-white p-4" @submit.prevent="handleUpload">
        <div class="flex justify-between items-center mb-3">
          <h3 class="font-semibold">Upload document</h3>
          <button type="button" class="text-xl" @click="openUpload = false">×</button>
        </div>

        <input type="file" @change="onFileChange" required />

        <div class="flex justify-end gap-2 mt-3">
          <button type="button" class="px-3 py-2 border" @click="openUpload = false">Cancel</button>
          <button type="submit" class="px-3 py-2 bg-red-700 text-white" :disabled="uploading">
            {{ uploading ? "Uploading…" : "Upload" }}
          </button>
        </div>

        <p v-if="uploadError" class="text-sm text-red-600 mt-2">{{ uploadError }}</p>
      </form>
    </div>

    <!-- Download Modal -->
    <div v-if="openDownload" class="fixed inset-0 grid place-items-center bg-black/50 p-4 z-50" @click.self="openDownload = false">
      <div class="w-full max-w-sm bg-white p-4">
        <div class="flex justify-between items-center mb-3">
          <h3 class="font-semibold">Download document</h3>
          <button type="button" class="text-xl" @click="openDownload = false">×</button>
        </div>

        <div class="flex justify-end gap-2">
          <button type="button" class="px-3 py-2 border" @click="openDownload = false">
            Cancel
          </button>
          <button type="button" class="px-3 py-2 bg-red-700 text-white" :disabled="downloading" @click="downloadPdf">
            {{ downloading ? "Downloading…" : "Download" }}
          </button>
        </div>

        <p v-if="downloadError" class="text-sm text-red-600 mt-2">{{ downloadError }}</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
type Student = { id: number; username: string; email?: string }

type DocSection = { id: string; title: string; content: string }

type PiField = "description" | "observations" | "medrec" | "activities" | "interacttutorial"
type DocSectionWithField = DocSection & { field?: PiField }

const router = useRouter()

const docVM = reactive<{ sections: DocSectionWithField[] }>({ sections: [] })

const students = ref<Student[]>([])
const selectedStudentId = ref<number | null>(null)
const loadingStudents = ref(false)
const loadingDoc = ref(false)
const docError = ref<string | null>(null)

async function checkEndpoint() {
  const res = await fetch("http://localhost:3000/me", {
    method: "GET",
    credentials: "include",
    headers: { "Content-Type": "application/json" },
  })

  const data = await res.json().catch(() => ({}))

  if (!data?.authenticated) {
    router.push("/areaPrivada")
    throw new Error("Not authenticated")
  }
}

const selectedStudentName = computed(() => {
  if (!selectedStudentId.value) return null
  return students.value.find(s => s.id === selectedStudentId.value)?.username ?? null
})

function scrollTo(sectionId: string) {
  const el = document.getElementById(`sec-${sectionId}`)
  if (!el) return
  el.scrollIntoView({ behavior: "smooth", block: "start" })
}

// Sidebar butts
function goToSummary() {
  if (!selectedStudentId.value) return
  router.push({
    path: "/summary",
    query: { studentId: String(selectedStudentId.value) },
  })
}

// Fetching
async function fetchStudents() {
  loadingStudents.value = true
  try {
    const res = await fetch("http://localhost:3000/teacher/students", {
      method: "GET",
      credentials: "include",
    })
    if (!res.ok) throw new Error(`Students fetch failed (${res.status})`)
    students.value = (await res.json()) as Student[]

    const first = students.value[0]
    if (first) await selectStudent(first.id)
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
    const res = await fetch(`http://localhost:3000/teacher/students/${studentId}/document`, {
      credentials: "include",
    })
    if (!res.ok) throw new Error(`Document fetch failed (${res.status})`)
    const data = await res.json()
    docVM.sections = (data.sections ?? []) as DocSectionWithField[]
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
  editingId.value = null
  saveError.value = null
  drafts.value = {}
  await fetchStudentDoc(studentId)
}

/** ===== Edit / Save (teacher) ===== */
const editingId = ref<string | null>(null)
const drafts = ref<Record<string, string>>({})
const saving = ref(false)
const saveError = ref<string | null>(null)

function startEdit(sec: DocSectionWithField) {
  saveError.value = null
  editingId.value = sec.id
  drafts.value[sec.id] = sec.content ?? ""
}

function cancelEdit(sec: DocSectionWithField) {
  saveError.value = null
  drafts.value[sec.id] = sec.content ?? ""
  editingId.value = null
}

async function saveSection(sec: DocSectionWithField) {
  if (!selectedStudentId.value) return
  saveError.value = null
  saving.value = true
  try {
    const newText = drafts.value[sec.id] ?? ""

    if (!sec.field) {
      // Kiril, you can remove this check once your endpoint includes field.
      throw new Error("This section is missing a 'field' mapping. Add it in the API so teacher edits know what to update.")
    }

    const body = { pi: { [sec.field]: newText } }

    // patch "/teacher/students/:id/pi", to: "teachers#update_student_pi"
    const res = await fetch(`http://localhost:3000/teacher/students/${selectedStudentId.value}/pi`, {
      method: "PATCH",
      credentials: "include",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    })

    const data = await res.json().catch(() => ({}))
    if (!res.ok) {
      throw new Error(data?.error || (data?.errors?.join?.(", ")) || `Save failed (${res.status})`)
    }

    const uwu = docVM.sections.findIndex(x => x.id === sec.id)
    const target = docVM.sections[uwu]

    if (target) {
      target.content = newText
    }

    editingId.value = null
  } catch (e: any) {
    saveError.value = e?.message ?? "Failed to save"
  } finally {
    saving.value = false
  }
}

// upload/download(for teacher)
const openUpload = ref(false)
const openDownload = ref(false)

const uploading = ref(false)
const uploadError = ref<string | null>(null)
const selectedFile = ref<File | null>(null)

function onFileChange(e: Event) {
  const input = e.target as HTMLInputElement
  selectedFile.value = input.files?.[0] ?? null
}

async function handleUpload() {
  if (!selectedStudentId.value) return
  if (!selectedFile.value) {
    uploadError.value = "Please select a file."
    return
  }

  uploading.value = true
  uploadError.value = null

  try {
    const formData = new FormData()
    formData.append("document", selectedFile.value)

    const res = await fetch(`http://localhost:3000/teacher/students/${selectedStudentId.value}/document`, {
      method: "POST",
      credentials: "include",
      body: formData,
    })

    const data = await res.json().catch(() => ({}))
    if (!res.ok) throw new Error(data?.error || `Upload failed (${res.status})`)

    openUpload.value = false
    selectedFile.value = null
    await fetchStudentDoc(selectedStudentId.value)
  } catch (e: any) {
    uploadError.value = e?.message ?? "Upload failed."
    console.error(e)
  } finally {
    uploading.value = false
  }
}

const downloading = ref(false)
const downloadError = ref<string | null>(null)

async function downloadPdf() {
  if (!selectedStudentId.value) return
  downloading.value = true
  downloadError.value = null

  try {
    const res = await fetch(`http://localhost:3000/teacher/students/${selectedStudentId.value}/document/download`, {
      method: "GET",
      credentials: "include",
    })
    if (!res.ok) throw new Error(`Download failed (${res.status})`)

    const blob = await res.blob()
    const url = URL.createObjectURL(blob)
    const a = document.createElement("a")
    a.href = url
    a.download = `student-${selectedStudentId.value}-document.pdf`
    a.click()
    URL.revokeObjectURL(url)

    openDownload.value = false
  } catch (e: any) {
    downloadError.value = e?.message ?? "Download failed."
    console.error(e)
  } finally {
    downloading.value = false
  }
}

onMounted(async () => {
  await checkEndpoint()
  await fetchStudents()
})
</script>
