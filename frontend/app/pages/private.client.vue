<template>
  <div class="max-w-5xl mx-auto px-4 py-6 min-h-screen bg-[#F7F7F7]">
    <div class="flex gap-4">
      <!-- Sidebar -->
      <aside class="w-56 shrink-0">
        <div
          class="sticky top-24 h-[calc(100vh-6rem)] overflow-auto border bg-white p-3"
        >
          <p class="font-semibold mb-2">Sections</p>

          <button
            v-for="s in docVM.sections"
            :key="s.id"
            type="button"
            class="block w-full text-left px-2 py-1 hover:bg-gray-100"
            @click="scrollTo(s.id)"
          >
            {{ s.title }}
          </button>
        </div>
      </aside>

      <!-- Main document -->
      <div class="flex-1">
        <h1>
          Greetings, our unique and special{{ username }}! This is your personal
          cabinet.
        </h1>
        <h2>Document</h2>

        <section
          v-for="section in docVM.sections"
          :key="section.id"
          :id="`sec-${section.id}`"
          class="mt-6 scroll-mt-24 border p-4 bg-white"
        >
          <div class="flex items-start justify-between gap-3">
            <h3 class="font-semibold">{{ section.title }}</h3>

            <div class="flex gap-2 shrink-0">
              <button
                v-if="editingId !== section.id"
                class="border px-3 py-1"
                type="button"
                @click="startEdit(section)"
              >
                Edit
              </button>

              <div v-else>
                <button
                  class="border px-3 py-1"
                  type="button"
                  :disabled="saving"
                  @click="saveSection(section)"
                >
                  Save
                </button>
                <button
                  class="border px-3 py-1"
                  type="button"
                  :disabled="saving"
                  @click="cancelEdit(section)"
                >
                  Cancel
                </button>
              </div>
            </div>
          </div>

          <p v-if="editingId !== section.id" class="mt-3 whitespace-pre-wrap">
            {{ section.content }}
          </p>

          <!-- Editable -->
          <div v-else class="mt-3">
            <textarea
              class="w-full border p-2 min-h-[140px]"
              v-model="drafts[section.id]"
            />
            <p v-if="saveError" class="text-red-600 mt-2">{{ saveError }}</p>
          </div>
        </section>
      </div>
    </div>

    <!-- Upload Status Display -->
    <div
      v-if="uploadStatus"
      class="fixed top-4 right-4 p-4 rounded shadow-lg z-50"
      :class="
        uploadStatus === 'completed'
          ? 'bg-green-100 border-green-300'
          : uploadStatus === 'failed'
            ? 'bg-red-100 border-red-300'
            : 'bg-blue-100 border-blue-300'
      "
    >
      <div v-if="uploadStatus === 'processing'" class="flex items-center gap-2">
        <div
          class="animate-spin h-4 w-4 border-2 border-blue-500 border-t-transparent rounded-full"
        ></div>
        <span>{{ uploadMessage }}</span>
      </div>
      <div v-else-if="uploadStatus === 'completed'" class="text-green-700">
        <p class="font-bold">Upload Complete!</p>
        <p class="text-sm">{{ uploadMessage }}</p>
      </div>
      <div v-else-if="uploadStatus === 'failed'" class="text-red-700">
        <p class="font-bold">Upload Failed</p>
        <p class="text-sm">{{ uploadMessage }}</p>
      </div>
    </div>

    <button
      class="fixed right-4 bottom-4 px-4 py-2 bg-red-700 text-white"
      type="button"
      @click="open = true"
    >
      Add document
    </button>
    <div
      v-if="open"
      class="fixed inset-0 grid place-items-center bg-black/50 p-4"
      @click.self="open = false"
    >
      <form class="w-full max-w-sm bg-white p-4" @submit.prevent="handleSubmit">
        <div class="flex justify-between items-center mb-3">
          <h3 class="font-semibold">Upload document</h3>
          <button type="button" class="text-xl" @click="open = false">×</button>
        </div>

        <input type="file" @change="onFileChange" required />

        <div class="flex justify-end gap-2 mt-3">
          <button type="button" class="px-3 py-2 border" @click="open = false">
            Cancel
          </button>
          <button type="submit" class="px-3 py-2 bg-red-700 text-white">
            Upload
          </button>
        </div>
      </form>
    </div>

    <button
      class="fixed right-4 bottom-[70px] px-4 py-2 bg-red-700 text-white"
      type="button"
      @click="open2 = true"
    >
      Descarrga document
    </button>

    <div
      v-if="open2"
      class="fixed inset-0 grid place-items-center bg-black/50 p-4"
      @click.self="open2 = false"
    >
      <div class="w-full max-w-sm bg-white p-4">
        <div class="flex justify-between items-center mb-3">
          <h3 class="font-semibold">Descarrega el document</h3>
          <button type="button" class="text-xl" @click="open2 = false">
            ×
          </button>
        </div>

        <div class="flex justify-end gap-2">
          <button type="button" class="px-3 py-2 border" @click="open2 = false">
            Cancel
          </button>
          <button
            type="button"
            class="px-3 py-2 bg-red-700 text-white"
            @click="downloadPdf"
          >
            Descàrrega
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import { ref, onMounted, onUnmounted } from "vue";
import { usePdfUploadCable } from "~/composables/useActionCable";
const router = useRouter();
const { username } = useUser();

// ActionCable setup
const cable = usePdfUploadCable("http://localhost:3000/cable");
const uploadStatus = ref<string | null>(null);
const uploadMessage = ref("");
const uploadSummary = ref("");
const uploadUnsubscribe = ref<(() => void) | null>(null);
type PiField =
  | "description"
  | "observations"
  | "medrec"
  | "activities"
  | "interacttutorial";

type DocSection = {
  id: number;
  title: string;
  content: string;
  field: PiField;
};

type DocumentVm = {
  title: string;
  sections: DocSection[];
};

const docVM: Ref<DocumentVm> = ref({ title: "PI #1", sections: [] });
const document2 = ref<File | null>(null);
const open = ref(false);
const open2 = ref(false);
const piId = 1;

const editingId = ref<number | null>(null);
const drafts = ref<Record<number, string>>({});
const saving = ref(false);
const saveError = ref<string | null>(null);

function onFileChange(e: Event) {
  const input = e.target as HTMLInputElement;
  document2.value = input.files?.[0] ?? null;
}

async function checkEndpoint() {
  const res = await fetch("http://localhost:3000/me", {
    method: "GET",
    credentials: "include",
    headers: {
      "Content-Type": "application/json",
    },
  });
  const data = await res.json();
  if (data.authenticated) {
    console.log("User authenticated");
  } else {
    router.push("/areaPrivada");
    console.log("User not authenticated");
  }
}

async function loadDocument() {
  try {
    const res = await fetch("http://localhost:3000/pis", {
      method: "GET",
      credentials: "include",
    });

    if (!res.ok) {
      console.error(`Failed to load PI: ${res.status}`);
      docVM.value = { title: "No PI yet", sections: [] };
      return;
    }

    const pi = await res.json();

    if (!pi || Object.keys(pi).length === 0) {
      console.log("No PI found for user");
      docVM.value = { title: "No PI yet", sections: [] };
      return;
    }

    console.log("PI loaded:", pi);

    docVM.value = {
      title: pi.title ?? `PI #${pi.id ?? ""}`,
      sections: [
        {
          id: 1,
          title: "Description",
          content: pi.description ?? "",
          field: "description",
        },
        {
          id: 2,
          title: "Observations",
          content: pi.observations ?? "",
          field: "observations",
        },
        {
          id: 3,
          title: "Medical record",
          content: pi.medrec ?? "",
          field: "medrec",
        },
        {
          id: 4,
          title: "Activities",
          content: pi.activities ?? "",
          field: "activities",
        },
        {
          id: 5,
          title: "Interaction tutorial",
        content: pi.interacttutorial ?? "",
        field: "interacttutorial",
      },
    ],
  };

  console.log("sections:", docVM.value.sections);
}

async function handleSubmit() {
  if (!document2.value) {
    alert("Please select a document to upload.");
    return;
  }

  if (!cable.isConnected) {
    alert("WebSocket not connected. Please refresh the page.");
    return;
  }

  uploadStatus.value = null;
  uploadMessage.value = "";
  uploadSummary.value = "";

  try {
    const formData = new FormData();
    formData.append("document", document2.value);

    const response = await fetch("http://localhost:3000/pis", {
      method: "POST",
      credentials: "include",
      body: formData,
    });

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.error || "Upload failed");
    }

    // Subscribe to the upload channel
    uploadUnsubscribe.value = cable.subscribeToPdfUpload(
      data.id,
      (update: any) => {
        console.log("Upload update:", update);
        uploadStatus.value = update.status;
        uploadMessage.value = update.message || "";
        if (update.status === "completed") {
          uploadSummary.value = update.summary || "";
          console.log("Ollama Summary:", update.summary);
          // Refresh the document list or show success
          loadDocument();
        }
      },
    );

    open.value = false;
  } catch (error: any) {
    alert(`Upload failed: ${error.message}`);
  }
}

async function downloadPdf() {
  try {
    const response = await fetch(`http://localhost:3000/pis/my-pi/download`, {
      method: "GET",
      credentials: "include",
    });

    if (!response.ok) throw new Error("Download failed");

    const blob = await response.blob();
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = "document.pdf";
    a.click();
    URL.revokeObjectURL(url);
  } catch (error: any) {
    alert(`Download failed: ${error.message}`);
  }
}

function scrollTo(id: number) {
  if (import.meta.server) return;

  window.document
    .getElementById(`sec-${id}`)
    ?.scrollIntoView({ behavior: "smooth", block: "start" });
}

function startEdit(section: DocSection) {
  saveError.value = null;
  editingId.value = section.id;
  drafts.value[section.id] = section.content;
}

function cancelEdit(section: DocSection) {
  saveError.value = null;
  drafts.value[section.id] = section.content;
  editingId.value = null;
}

async function saveSection(section: DocSection) {
  saveError.value = null;
  saving.value = true;

  try {
    const newText = drafts.value[section.id] ?? "";

    const body = { pi: { [section.field]: newText } };

    const res = await fetch(`http://localhost:3000/pis/${piId}`, {
      method: "PATCH",
      credentials: "include",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    });

    const data = await res.json().catch(() => ({}));
    if (!res.ok) {
      throw new Error(
        data?.error ||
          data?.errors?.join?.(", ") ||
          `Save failed (${res.status})`,
      );
    }

    const idx = docVM.value.sections.findIndex((x) => x.id === section.id);
    const target = docVM.value.sections[idx];
    if (target) target.content = newText;

    editingId.value = null;
  } catch (e: any) {
    saveError.value = e?.message ?? "Failed to save";
  } finally {
    saving.value = false;
  }
}

onMounted(async () => {
  await checkEndpoint();
  await loadDocument();

  // Setup ActionCable
  cable.connect();
  console.log("WebSocket connecting for uploads...");
});

onUnmounted(() => {
  if (uploadUnsubscribe.value) {
    uploadUnsubscribe.value();
    uploadUnsubscribe.value = null;
  }
  cable.disconnect();
});
</script>
