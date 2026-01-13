<template>
  <div class="bg-[#404040] w-full">
    <h1 class=" text-[24px] text-white max-w-5xl mx-auto px-4 py-3">Upload Document</h1>
  </div>

  <div class="max-w-5xl mx-auto px-4 py-6">
    <form class="bg-white min-h-screen flex flex-col mt-10 text-xl" @submit.prevent="handleSubmit">
      <label for="document" class="mt-4">Document</label>
      <input class="border border-black p-2" type="file" id="document" accept="application/pdf"
        @change="onFileChange" />

      <button class="bg-[#CC0000] text-white p-2 mt-4 w-auto" type="submit">
        Upload Document
      </button>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue";

const document = ref<File | null>(null);

//Gets the document on change, so the document.value never stays null
function onFileChange(event: Event) {
  const target = event.target as HTMLInputElement;
  const file = target.files?.[0];

  if (!file) return;

  if (file.type !== "application/pdf") {
    alert("Only PDF files are allowed.");
    target.value = ""; // reset input
    document.value = null;
    return;
  }
  document.value = file;
}


async function handleSubmit() {
  if (!document.value) {
    alert("Please select a document to upload.");
    return;
  }

  const formData = new FormData();
  formData.append("document", document.value);

  const res = await fetch("http://localhost:3000/upload", {
    method: "POST",
    credentials: "include",
    body: formData,
  });
  const data = await res.json();
  console.log(data);
}
</script>
