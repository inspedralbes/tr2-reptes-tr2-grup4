<template>  
    <div class="max-w-5xl mx-auto px-4 py-6 min-h-screen">
        <h1>Greetings, our unique and special {{ username }}! This is your personal cabinet.</h1>
        <h2>Document</h2>
        <section v-for="section in document.sections" :key="section.id">
            <h3>{{ section.title }}</h3>
            <p>{{ section.content }}</p>
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
            <input id="document" type="file" class="w-full border p-2 mb-3" />

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
    </div>
</template>

<script setup lang="ts">
    import { ref } from "vue";
    const router = useRouter();
    const { username } = useUser();
    type DocSection = { id: number; title: string; content: string }
    type DocumentVm = { title: string; sections: DocSection[] }

    const document = ref<DocumentVm>({ title: "PI #1", sections: [] });
    const document2 = ref<File | null>(null);
    const open = ref(false)

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

        document.value = {
            title: pi.title ?? `PI #${pi.id ?? 1}`,
            sections: [
            { id: 1, title: "Description", content: pi.description ?? "" },
            { id: 2, title: "Observations", content: pi.observations ?? "" },
            { id: 3, title: "Medical record", content: pi.medrec ?? "" },
            { id: 4, title: "Activities", content: pi.activities ?? "" },
            { id: 5, title: "Tutorial interaction", content: pi.interacttutorial ?? "" },
            ],
        }

        console.log("sections:", document.value.sections)
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

    onMounted(async () => {
        await checkEndpoint();
        loadDocument();
    });

</script>