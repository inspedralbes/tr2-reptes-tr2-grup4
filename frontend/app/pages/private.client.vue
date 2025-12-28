<template>
 <p>This is personal cabinet</p>

</template>

<script setup lang="ts">
    const router = useRouter()
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

    onMounted(async () => {
        await checkEndpoint();
    });

</script>