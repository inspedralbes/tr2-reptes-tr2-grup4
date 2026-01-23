import { ref, reactive } from "vue";

type Subscription = {
  subscriptionId: string;
  callback: (data: any) => void;
};

export function useActionCable(url: string) {
  const socket = ref<WebSocket | null>(null);
  const isConnected = ref(false);

  const subscriptions = reactive<Record<string, Subscription>>({});

  let reconnectAttempts = 0;
  let manualDisconnect = false;

  function normalizeWsUrl(url: string) {
    if (url.startsWith("http://")) return url.replace("http://", "ws://");
    if (url.startsWith("https://")) return url.replace("https://", "wss://");
    return url;
  }

  function connect() {
    if (socket.value?.readyState === WebSocket.OPEN) return;

    manualDisconnect = false;
    const wsUrl = normalizeWsUrl(url);
    socket.value = new WebSocket(wsUrl);

    socket.value.onopen = () => {
      isConnected.value = true;
      reconnectAttempts = 0;
      console.log("[ActionCable] Connected");

      Object.values(subscriptions).forEach(({ subscriptionId }) => {
        socket.value?.send(
          JSON.stringify({
            command: "subscribe",
            identifier: subscriptionId,
          }),
        );
      });
    };

    socket.value.onclose = () => {
      isConnected.value = false;
      socket.value = null;

      if (manualDisconnect) {
        console.log("[ActionCable] Disconnected manually");
        return;
      }

      reconnectAttempts++;
      const timeout = Math.min(1000 * reconnectAttempts, 10000);

      console.log(
        `[ActionCable] Disconnected. Reconnecting in ${timeout}ms...`,
      );

      setTimeout(() => {
        if (!isConnected.value) {
          connect();
        }
      }, timeout);
    };

    socket.value.onerror = (error) => {
      console.error("[ActionCable] Error:", error);
    };

    socket.value.onmessage = (event) => {
      let data: any;

      try {
        data = JSON.parse(event.data);
      } catch {
        console.warn("[ActionCable] Invalid JSON:", event.data);
        return;
      }

      if (data.type === "ping") return;

      if (data.type === "confirm_subscription") {
        console.log(
          "[ActionCable] Subscription confirmed:",
          data.identifier,
        );
        return;
      }

      if (data.type === "reject_subscription") {
        console.error(
          "[ActionCable] Subscription rejected:",
          data.identifier,
        );
        return;
      }

      if (data.identifier && data.message) {
        const subscription = subscriptions[data.identifier];

        if (subscription) {
          subscription.callback(data.message);
        } else {
          console.warn(
            "[ActionCable] No subscription found for:",
            data.identifier,
          );
        }
      }
    };
  }

  function subscribe(
    channelName: string,
    params: Record<string, any>,
    callback: (data: any) => void,
  ) {
    const subscriptionId = JSON.stringify({
      channel: channelName,
      ...params,
    });

    subscriptions[subscriptionId] = {
      subscriptionId,
      callback,
    };

    if (isConnected.value && socket.value?.readyState === WebSocket.OPEN) {
      socket.value.send(
        JSON.stringify({
          command: "subscribe",
          identifier: subscriptionId,
        }),
      );
    }
  }

  function unsubscribe(channelName: string, params: Record<string, any>) {
    const subscriptionId = JSON.stringify({
      channel: channelName,
      ...params,
    });

    delete subscriptions[subscriptionId];

    if (isConnected.value && socket.value) {
      socket.value.send(
        JSON.stringify({
          command: "unsubscribe",
          identifier: subscriptionId,
        }),
      );
    }
  }

  function disconnect() {
    manualDisconnect = true;
    isConnected.value = false;

    Object.keys(subscriptions).forEach((key) => delete subscriptions[key]);

    socket.value?.close();
    socket.value = null;
  }

  return {
    isConnected,
    connect,
    disconnect,
    subscribe,
    unsubscribe,
  };
}

export function usePdfUploadCable(url: string) {
  const cable = useActionCable(url);

  function subscribeToPdfUpload(
    id: number,
    callback: (data: any) => void,
  ) {
    cable.subscribe("PdfUploadChannel", { id }, callback);
    return () => cable.unsubscribe("PdfUploadChannel", { id });
  }

  return {
    ...cable,
    subscribeToPdfUpload,
  };
}
