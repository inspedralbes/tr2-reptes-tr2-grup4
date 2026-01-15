<template>
  <div class="bg-[#404040] w-full">
    <h1 class="text-[24px] text-white max-w-5xl mx-auto px-4 py-3">Upload Document</h1>
  </div>

  <div class="max-w-5xl mx-auto px-4 py-6">
    <div v-if="status" class="mb-4 p-4 rounded" :class="statusClass">
      <div v-if="status === 'processing'">
        <p class="font-bold">Processing your PDF...</p>
        <p class="text-sm">{{ statusMessage }}</p>
        <div class="mt-2 animate-spin h-6 w-6 border-4 border-blue-500 border-t-transparent rounded-full"></div>
      </div>

      <div v-else-if="status === 'completed'">
        <p class="font-bold text-green-600">Processing Complete!</p>
        <div class="mt-2 p-3 bg-white rounded border">
          <p class="text-sm font-bold">Summary:</p>
          <p class="mt-1">{{ summary }}</p>
        </div>
      </div>

      <div v-else-if="status === 'failed'">
        <p class="font-bold text-red-600">Processing Failed</p>
        <p class="text-sm">{{ errorMessage }}</p>
      </div>
    </div>

    <form class="bg-white min-h-screen flex flex-col mt-10 text-xl" @submit.prevent="handleSubmit">
      <label for="document" class="mt-4">Document</label>
      <input class="border border-black p-2" type="file" id="document" accept="application/pdf"
        @change="onFileChange" />

      <button class="bg-[#CC0000] text-white p-2 mt-4 w-auto" type="submit" :disabled="isUploading">
        {{ isUploading ? 'Uploading...' : 'Upload Document' }}
      </button>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'

const document = ref<File | null>(null)
const isUploading = ref(false)
const status = ref<string | null>(null)
const summary = ref('')
const errorMessage = ref('')
const statusMessage = ref('')
const unsubscribe = ref<(() => void) | null>(null)

const cable = ref<any>(null)

onMounted(() => {
  cable.value = usePdfUploadCable('ws://localhost:3000/cable')
  cable.value.connect()
  console.log('WebSocket connecting...')
})

onUnmounted(() => {
  if (unsubscribe.value) {
    unsubscribe.value()
    unsubscribe.value = null
  }
  if (cable.value) {
    cable.value.disconnect()
    cable.value = null
  }
})

const statusClass = computed(() => {
  switch (status.value) {
    case 'processing': return 'bg-blue-50 border border-blue-200'
    case 'completed': return 'bg-green-50 border border-green-200'
    case 'failed': return 'bg-red-50 border border-red-200'
    default: return ''
  }
})

function onFileChange(event: Event) {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]

  if (!file) return

  if (file.type !== 'application/pdf') {
    alert('Only PDF files are allowed.')
    target.value = ''
    document.value = null
    return
  }

  document.value = file
}

async function handleSubmit() {
  if (!document.value) {
    alert('Please select a document to upload.')
    return
  }

  if (!cable.value) {
    alert('WebSocket not connected. Please refresh the page.')
    return
  }

  // Wait for connection to be established
  if (!cable.value.isConnected.value) {
    console.log('Waiting for connection...')
    await new Promise(resolve => setTimeout(resolve, 500))
    if (!cable.value.isConnected.value) {
      alert('WebSocket still not connected. Please try again.')
      return
    }
  }

  isUploading.value = true
  status.value = null
  summary.value = ''
  errorMessage.value = ''
  statusMessage.value = ''

  try {
    const formData = new FormData()
    formData.append('document', document.value)

    const res = await fetch('http://localhost:3000/upload', {
      method: 'POST',
      credentials: 'include',
      body: formData,
    })

    const data = await res.json()

    if (!res.ok) {
      throw new Error(data.error || 'Upload failed')
    }

    unsubscribe.value = cable.value.subscribeToPdfUpload(data.id, (update: any) => {
      console.log('Received update:', update)
      console.log('Current status before:', status.value)
      switch (update.status) {
        case 'processing':
          status.value = 'processing'
          statusMessage.value = update.message || 'Processing...'
          break
        case 'completed':
          status.value = 'completed'
          summary.value = update.summary || ''
          break
        case 'failed':
          status.value = 'failed'
          errorMessage.value = update.error || 'Unknown error'
          break
      }
      console.log('Current status after:', status.value)
    })

  } catch (error) {
    status.value = 'failed'
    errorMessage.value = error instanceof Error ? error.message : 'Upload failed'
  } finally {
    isUploading.value = false
  }
}
</script>
