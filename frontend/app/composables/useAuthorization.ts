import { useRouter } from "vue-router";

export async function useAuthorization(requiredRole?: string) {
  const router = useRouter();

  const checkAuthorization = async (): Promise<{
    authenticated: boolean;
    role?: string;
    user?: any;
  }> => {
    try {
      const res = await fetch("http://localhost:3000/me", {
        method: "GET",
        credentials: "include",
        headers: {
          "Content-Type": "application/json",
        },
      });

      const data = await res.json();

      if (!data.authenticated) {
        router.push("/login");
        return { authenticated: false };
      }

      // Validar rol si se requiere uno específico
      if (requiredRole && data.user?.role !== requiredRole) {
        // Redirigir al login del rol correspondiente
        if (data.user?.role === "teacher") {
          router.push("/loginTeacher");
        } else if (data.user?.role === "student") {
          router.push("/login");
        } else {
          router.push("/loginAdmin");
        }
        return { authenticated: false };
      }

      return {
        authenticated: true,
        role: data.user?.role,
        user: data.user,
      };
    } catch (error) {
      console.error("Error checking authorization:", error);
      router.push("/login");
      return { authenticated: false };
    }
  };

  return {
    checkAuthorization,
  };
}
