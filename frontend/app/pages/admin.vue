<template>
  <div class="min-h-screen bg-[#f5f5f5] text-[#333]">
    <!-- LOADING / CHECKING AUTHORIZATION -->
    <div
      v-if="!isAuthorized"
      class="flex items-center justify-center min-h-screen"
    >
      <div class="text-center">
        <div class="mb-4">
          <div
            class="inline-block animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500"
          ></div>
        </div>
        <p class="text-gray-600">Verificant autorització...</p>
      </div>
    </div>

    <!-- MAIN CONTENT (Only show if authorized) -->
    <template v-if="isAuthorized">
      <!-- HEADER -->
      <header class="bg-white border-b border-gray-300">
        <div class="max-w-7xl mx-auto px-6 py-4">
          <h1 class="text-xl font-semibold">
            Administració · Assignació d’alumnes i professorat
          </h1>
        </div>
      </header>

      <div class="flex max-w-7xl mx-auto">
        <!-- SIDEBAR -->
        <aside
          class="w-64 bg-white border-r border-gray-300 min-h-[calc(100vh-72px)]"
        >
          <nav class="px-4 py-6 space-y-1 text-sm">
            <!-- ASSIGNACIONS -->
            <button
              class="w-full text-left px-3 py-2 rounded font-medium bg-gray-100"
              @click="selectedStudentId = null"
            >
              Assignacions
            </button>

            <!-- ALUMNAT -->
            <div>
              <p
                class="px-3 py-1 text-xs uppercase text-gray-500 tracking-wide"
              >
                Alumnat
              </p>

              <ul class="mt-2 space-y-1 max-h-[60vh] overflow-y-auto">
                <li v-for="student in students" :key="student.id">
                  <button
                    class="w-full text-left px-3 py-2 rounded hover:bg-gray-100"
                    :class="{
                      'bg-gray-200 font-medium':
                        student.id === selectedStudentId,
                    }"
                    @click="selectStudent(student.id)"
                  >
                    {{ student.username }}
                  </button>
                </li>
              </ul>
            </div>
          </nav>
        </aside>

        <!-- MAIN -->
        <main class="flex-1 px-8 py-8">
          <!-- PAGE INTRO -->
          <section class="mb-6 max-w-4xl">
            <h2 class="text-2xl font-semibold mb-2">
              Assignació d’alumnes a professorat
            </h2>
            <p class="text-gray-700">
              Des d’aquest espai podeu assignar un professor o professora
              responsable a cada alumne amb Pla de Suport Individualitzat.
            </p>
          </section>

          <!-- TABLE -->
          <section class="bg-white border border-gray-300">
            <table class="w-full text-sm">
              <thead class="bg-gray-100 border-b">
                <tr>
                  <th class="text-left px-4 py-3 font-semibold">Alumne</th>
                  <th class="text-left px-4 py-3 font-semibold">
                    Professor/a assignat/da
                  </th>
                  <th class="text-left px-4 py-3 font-semibold">Accions</th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="student in filteredStudents"
                  :key="student.id"
                  class="border-b hover:bg-gray-50"
                >
                  <td class="px-4 py-3">{{ student.username }}</td>

                  <td>
                    <span v-if="student.teacher">{{
                      student.teacher.username
                    }}</span>
                    <span v-else class="text-gray-600">— Sense assignar —</span>
                  </td>

                  <!-- <td class="px-4 py-3 text-gray-600"></td> -->

                  <td class="px-4 py-3">
                    <button
                      class="text-[#C00000] hover:underline font-medium"
                      @click="openAssignModal(student)"
                    >
                      {{ student.teacher ? "Canviar" : "Assignar" }}
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </section>
        </main>
      </div>
      <!-- MODAL ASSIGNAR PROFESSOR -->
      <div
        v-if="showAssignModal"
        class="fixed inset-0 bg-black/40 flex items-center justify-center z-50"
      >
        <div class="bg-white w-full max-w-md border border-gray-300">
          <!-- Header -->
          <div class="px-6 py-4 border-b flex justify-between items-center">
            <h3 class="font-semibold text-lg">Assignar professor/a</h3>
            <button @click="closeModal" class="text-gray-500 text-xl">×</button>
          </div>

          <!-- Body -->
          <div class="px-6 py-5 text-sm">
            <p class="mb-4 text-gray-700">
              Seleccioneu el professor o professora responsable per a:
              <strong>{{ selectedStudent?.username }}</strong>
            </p>

            <div
              v-if="assignmentError"
              class="mb-4 p-3 bg-red-100 text-red-700 rounded"
            >
              {{ assignmentError }}
            </div>

            <label class="block mb-2 font-medium"> Professor/a </label>
            <select
              v-model="selectedTeacherId"
              class="w-full border border-gray-300 px-3 py-2 rounded"
            >
              <option disabled value="">Seleccioneu una opció</option>
              <option
                v-for="teacher in teachers"
                :key="teacher.id"
                :value="teacher.id"
              >
                {{ teacher.username }}
              </option>
            </select>
          </div>

          <!-- Footer -->
          <div class="px-6 py-4 border-t flex justify-end gap-3">
            <button
              class="px-4 py-2 border border-gray-300 rounded"
              @click="closeModal"
            >
              Cancel·lar
            </button>

            <button
              class="px-4 py-2 bg-[#C00000] text-white rounded disabled:opacity-50"
              :disabled="!selectedTeacherId || isLoadingAssignment"
              @click="saveAssignment"
            >
              {{ isLoadingAssignment ? "Guardant..." : "Guardar" }}
            </button>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from "vue";
import { useRouter } from "vue-router";

const router = useRouter();

const isAuthorized = ref(false);
const students = ref<any[]>([]);
const teachers = ref<any[]>([]);

const showAssignModal = ref(false);
const selectedStudent = ref<any>(null); // ← Aquesta és la variable pel modal
const selectedTeacherId = ref<number | null>(null);
const isLoadingAssignment = ref(false);
const assignmentError = ref("");

const selectedStudentId = ref<number | null>(null); // ← Aquesta és per la sidebar

// CANVI: Reanomena la funció per evitar conflicte
function selectStudent(id: number) {
  selectedStudentId.value = id;
}

onMounted(async () => {
  // Check authorization - redirect if not admin
  try {
    const userData = (await $fetch("/api/me", {
      credentials: "include",
    })) as any;

    if (!userData || userData.user?.role !== "admin") {
      // Not authenticated or not admin - redirect to admin login
      router.push("/loginAdmin");
      return;
    }

    isAuthorized.value = true;
  } catch (error) {
    // No session - redirect to admin login
    router.push("/loginAdmin");
    return;
  }

  const response = (await $fetch("/api/admin/assignments", {
    credentials: "include",
  })) as any;

  students.value = response.students;
  teachers.value = response.teachers;
});

const filteredStudents = computed(() => {
  if (!selectedStudentId.value) {
    return students.value;
  }

  return students.value.filter((s) => s.id === selectedStudentId.value);
});

function openAssignModal(student: any) {
  selectedStudent.value = student;
  selectedTeacherId.value = student.teacher?.id || null;
  showAssignModal.value = true;
}

function closeModal() {
  showAssignModal.value = false;
  selectedStudent.value = null;
  assignmentError.value = "";
  isLoadingAssignment.value = false;
}

async function saveAssignment() {
  isLoadingAssignment.value = true;
  assignmentError.value = "";

  try {
    await $fetch(
      `/api/admin/assignments/${selectedStudent.value.id}`,
      {
        method: "PATCH",
        body: {
          teacher_id: selectedTeacherId.value,
        },
        credentials: "include",
      },
    );

    const teacher = teachers.value.find(
      (t) => t.id === selectedTeacherId.value,
    );
    selectedStudent.value.teacher = teacher;

    closeModal();
  } catch (error: any) {
    assignmentError.value = error?.message || "Error al guardar l'assignació";
    console.error("Error saving assignment:", error);
  } finally {
    isLoadingAssignment.value = false;
  }
}
</script>
