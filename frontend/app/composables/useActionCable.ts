import { ref, onMounted, onUnmounted } from 'vue'

export function useActionCable(url: string) {
  const socket = ref<WebSocket | null>(null)
  const isConnected = ref(false)
  const subscriptions = ref<Record<string, { subscriptionId: string; callback: (data: any) => void }>>({})

  function connect() {
    if (socket.value?.readyState === WebSocket.OPEN) return

    socket.value = new WebSocket(url)

    socket.value.onopen = () => {
      isConnected.value = true
      console.log('[ActionCable] Connected')
      // Re-subscribe to all channels
      Object.keys(subscriptions.value).forEach(channelKey => {
        const { subscriptionId } = subscriptions.value[channelKey]
        console.log('[ActionCable] Re-subscribing to:', subscriptionId, 'for channel:', channelKey)
        socket.value?.send(JSON.stringify({ command: 'subscribe', identifier: subscriptionId }))
      })
    }

    socket.value.onclose = () => {
      isConnected.value = false
      socket.value = null
      console.log('[ActionCable] Disconnected')
      // Try to reconnect after 1 second
      setTimeout(() => {
        if (!isConnected.value) {
          console.log('[ActionCable] Reconnecting...')
          connect()
        }
      }, 1000)
    }

    socket.value.onerror = (error) => {
      console.error('[ActionCable] Error:', error)
    }

    socket.value.onmessage = (event) => {
      const data = JSON.parse(event.data)
      console.log('[ActionCable] Raw message:', JSON.stringify(data, null, 2))

      if (data.type === 'confirm_subscription') {
        console.log('[ActionCable] Subscription confirmed for:', data.identifier)
      } else if (data.type === 'reject_subscription') {
        console.error('[ActionCable] Subscription rejected for:', data.identifier)
      } else if (data.identifier && data.message) {
        console.log('[ActionCable] Broadcast message:', data)
        const channelKey = data.identifier
        const subscription = subscriptions.value[channelKey]
        if (subscription) {
          console.log('[ActionCable] Calling callback for:', channelKey)
          subscription.callback(data.message)
        } else {
          console.warn('[ActionCable] No callback found for:', channelKey)
          console.log('[ActionCable] Available subscriptions:', Object.keys(subscriptions.value))
        }
      } else if (data.type === 'ping') {
        // Ignore ping messages
      } else {
        console.log('[ActionCable] Unhandled message type:', data.type)
      }
    }
  }

  function subscribe(channelName: string, params: Record<string, any>, callback: (data: any) => void) {
    const subscriptionId = JSON.stringify({ channel: channelName, ...params })
    const channelKey = `pdf_upload_${params.id}`
    console.log('[ActionCable] Subscribing to:', subscriptionId, 'channel key:', channelKey, 'isConnected:', isConnected.value)
    subscriptions.value[channelKey] = { subscriptionId, callback }

    if (isConnected.value && socket.value?.readyState === WebSocket.OPEN) {
      console.log('[ActionCable] Sending subscribe command')
      socket.value.send(JSON.stringify({ command: 'subscribe', identifier: subscriptionId }))
    } else {
      console.log('[ActionCable] Cannot subscribe - not connected yet, will retry on open')
    }
  }

  function unsubscribe(channelName: string, params: Record<string, any>) {
    const subscriptionId = JSON.stringify({ channel: channelName, ...params })
    const channelKey = `pdf_upload_${params.id}`
    delete subscriptions.value[channelKey]
    if (isConnected.value) {
      socket.value?.send(JSON.stringify({ command: 'unsubscribe', identifier: subscriptionId }))
    }
  }

  function disconnect() {
    if (socket.value) {
      socket.value.close()
      socket.value = null
    }
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
