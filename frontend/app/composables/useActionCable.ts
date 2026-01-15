import { onMounted, onUnmounted, ref } from 'vue'

export function useActionCable(url: string) {
  const socket = ref<WebSocket | null>(null)
  const isConnected = ref(false)
  const subscriptions = ref<Record<string, (data: any) => void>>({})

  function connect() {
    if (socket.value?.readyState === WebSocket.OPEN) return

    socket.value = new WebSocket(url)

    socket.value.onopen = () => {
      isConnected.value = true
      Object.keys(subscriptions.value).forEach(identifier => {
        socket.value?.send(JSON.stringify({ command: 'subscribe', identifier }))
      })
    }

    socket.value.onclose = () => {
      isConnected.value = false
      socket.value = null
    }

    socket.value.onerror = (error) => {
      console.error('WebSocket error:', error)
    }

    socket.value.onmessage = (event) => {
      const data = JSON.parse(event.data)
      if (data.type === 'message' && data.message && data.identifier) {
        const callback = subscriptions.value[data.identifier]
        if (callback) callback(data.message)
      }
    }
  }

  function subscribe(channelName: string, params: Record<string, any>, callback: (data: any) => void) {
    const identifier = JSON.stringify({ channel: channelName, ...params })
    subscriptions.value[identifier] = callback
    if (isConnected.value) {
      socket.value?.send(JSON.stringify({ command: 'subscribe', identifier }))
    }
  }

  function unsubscribe(channelName: string, params: Record<string, any>) {
    const identifier = JSON.stringify({ channel: channelName, ...params })
    delete subscriptions.value[identifier]
    if (isConnected.value) {
      socket.value?.send(JSON.stringify({ command: 'unsubscribe', identifier }))
    }
  }

  function disconnect() {
    socket.value?.close()
    socket.value = null
    isConnected.value = false
    subscriptions.value = {}
  }

  return {
    isConnected,
    connect,
    disconnect,
    subscribe,
    unsubscribe
  }
}

export function usePdfUploadCable(url: string) {
  const cable = useActionCable(url)

  function subscribeToPdfUpload(id: number, callback: (data: any) => void) {
    cable.subscribe('PdfUploadChannel', { id }, callback)
    return () => cable.unsubscribe('PdfUploadChannel', { id })
  }

  return {
    ...cable,
    subscribeToPdfUpload
  }
}
