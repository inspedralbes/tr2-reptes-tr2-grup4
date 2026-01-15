<template>  
    <div class="max-w-5xl mx-auto px-4 py-6 min-h-screen">
        <h1>Greetings, our unique and special {{ username }}! This is your personal cabinet.</h1>
        <h2>Document</h2>
        <aside class="fixed left-4 top-24 w-48 border bg-white p-2">
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
        </aside>
        <section
            v-for="section in docVM.sections"
            :key="section.id"
            :id="`sec-${section.id}`"
            class="mt-6 scroll-mt-24 border rounded-lg p-4 bg-white"
            >
            <div class="flex items-start justify-between gap-3">
                <h3 class="font-semibold">{{ section.title }}</h3>

                <div class="flex gap-2 shrink-0">
                <button
                    v-if="editingId !== section.id"
                    class="border rounded px-3 py-1"
                    type="button"
                    @click="startEdit(section)"
                >
                    Edit
                </button>

                <template v-else>
                    <button
                    class="border rounded px-3 py-1"
                    type="button"
                    :disabled="saving"
                    @click="saveSection(section)"
                    >
                    Save
                    </button>
                    <button
                    class="border rounded px-3 py-1"
                    type="button"
                    :disabled="saving"
                    @click="cancelEdit(section)"
                    >
                    Cancel
                    </button>
                </template>
                </div>
            </div>

            <!-- Read-only -->
            <p v-if="editingId !== section.id" class="mt-3 whitespace-pre-wrap">
                {{ section.content }}
            </p>

            <!-- Editable -->
            <div v-else class="mt-3">
                <textarea
                class="w-full border rounded p-2 min-h-[140px]"
                v-model="drafts[section.id]"
                />
                <p v-if="saveError" class="text-red-600 mt-2">{{ saveError }}</p>
            </div>
        </section>
        <button class="fixed right-4 bottom-4 px-4 py-2 bg-red-700 text-white"
            type="button"
            @click="open = true">
            Add document
        </button>
        <div v-if="open"
            class="fixed inset-0 grid place-items-center bg-black/50 p-4"
            @click.self="open = false">

            <form class="w-full max-w-sm bg-white p-4"
                @submit.prevent="handleSubmit">
            <div class="flex justify-between items-center mb-3">
                <h3 class="font-semibold">Upload document</h3>
                <button type="button" class="text-xl" @click="open = false">×</button>
            </div>

            <label for="document" class="block mb-2">Document</label>
            <input id="document" type="file" class="w-full border p-2 mb-3" @change="onFileChange" />

            <div class="flex justify-end gap-2">
                <button type="button" class="px-3 py-2 border" @click="open = false">
                Cancel
                </button>
                <button type="submit" class="px-3 py-2 bg-red-700 text-white">
                Upload
                </button>
            </div>
            </form>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
    import { ref } from "vue";
    const router = useRouter();
    const { username } = useUser();
    type PiField = "description" | "observations" | "medrec" | "activities" | "interacttutorial"
    type DocSection = { id: number; title: string; content: string; field: PiField}
    type DocumentVm = { title: string; sections: DocSection[] }

    const docVM = ref<DocumentVm>({ title: "PI #1", sections: [] });
    const document2 = ref<File | null>(null);
    const open = ref(false)
    
    function onFileChange(e: Event) {
        const input = e.target as HTMLInputElement
        document2.value = input.files?.[0] ?? null
    }

    async function checkEndpoint() {
        const res = await fetch("http://localhost:3000/me", {
            method: "GET",
            credentials: "include",
            headers: {
                "Content-Type": "application/json",
            },
        });
        const data = await res.json()
        if (data.authenticated) {
            console.log("User authenticated");
        } else {
            router.push("/areaPrivada");
            console.log("User not authenticated");
        }
    }

    async function loadDocument() {
        const res = await fetch("http://localhost:3000/pis/1", {
        credentials: "include"
        });
        if (!res.ok) throw new Error(`Failed to load PI: ${res.status}`)

        const pi = await res.json()

        docVM.value = {
            title: pi.title ?? `PI #${pi.id ?? 1}`,
            sections: [
                { id: 1, title: "Description", content: pi.description ?? "", field: "description" },
                { id: 2, title: "Observations", content: pi.observations ?? "", field: "observations" },
                { id: 3, title: "Medical record", content: pi.medrec ?? "", field: "medrec" },
                { id: 4, title: "Activities", content: pi.activities ?? "", field: "activities" },
                { id: 5, title: "Tutorial interaction", content: pi.interacttutorial ?? "", field: "interacttutorial" },
            ],
        }

        console.log("sections:", docVM.value.sections)
    }

    async function handleSubmit() {
        if (!document2.value) {
            alert("Please select a document to upload.");
            return;
        }

        const formData = new FormData();
        formData.append("document", document2.value);

        await fetch("http://localhost:3000/upload", {
            method: "POST",
            credentials: "include",
            body: formData,
        });
        open.value = false
    }

    function scrollTo(id: number) {
        if (import.meta.server) return;

        window.document
            .getElementById(`sec-${id}`)
            ?.scrollIntoView({ behavior: "smooth", block: "start" });
    }

    const piId = 1 // later you can take it from route params
    const editingId = ref<number | null>(null)
    const drafts = ref<Record<number, string>>({})
    const saving = ref(false)
    const saveError = ref<string | null>(null)

    function startEdit(section: DocSection) {
        saveError.value = null
        editingId.value = section.id
        drafts.value[section.id] = section.content
    }

    function cancelEdit(section: DocSection) {
        saveError.value = null
        drafts.value[section.id] = section.content
        editingId.value = null
    }

    async function saveSection(section: DocSection) {
        saveError.value = null
        saving.value = true

        try {
            const newText = drafts.value[section.id] ?? ""

            // Patch only the field you’re editing
            const body = { pi: { [section.field]: newText } }

            const res = await fetch(`http://localhost:3000/pis/${piId}`, {
            method: "PATCH",
            credentials: "include",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(body),
            })

            const data = await res.json().catch(() => ({}))
            if (!res.ok) {
            throw new Error(data?.error || (data?.errors?.join?.(", ")) || `Save failed (${res.status})`)
            }

            // Update local UI
            const idx = docVM.value.sections.findIndex((x) => x.id === section.id)
            const target = docVM.value.sections[idx]
            if (target) target.content = newText

            editingId.value = null
        } catch (e: any) {
            saveError.value = e?.message ?? "Failed to save"
        } finally {
            saving.value = false
        }
    }

    onMounted(async () => {
        await checkEndpoint();
        loadDocument();
    });

</script>