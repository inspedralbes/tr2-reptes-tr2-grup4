<template>
 <h1>Greetings, {{ username }}! This is your personal cabinet.</h1>
 <h2>Document</h2>
 <h3>Part 1</h3>
 <p>Some bs here, so it looked like I was doing something</p>
 <h3>Part 2</h3>
 <p>Some more bs</p>
 <h3>Part 3</h3>
 <p>Some more bs</p>
</template>

<script setup lang="ts">
    const router = useRouter();
    const { username } = useUser()
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