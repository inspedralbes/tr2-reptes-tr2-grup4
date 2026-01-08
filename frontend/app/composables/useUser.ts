import { ref } from "vue"

const username = ref("")

export function useUser() {
  const username = useState<string>("username", () => "")
  return { username }
}