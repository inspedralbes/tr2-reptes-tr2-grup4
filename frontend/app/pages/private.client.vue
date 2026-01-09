<template>
 <h1>Greetings, our unique and special {{ username }}! This is your personal cabinet.</h1>
 <h2>Document</h2>
 <section v-for="section in document.sections" :key="section.id">
    <h3>{{ section.title }}</h3>
    <p>{{ section.content }}</p>
 </section>
</template>

<script setup lang="ts">
    const router = useRouter();
    const { username } = useUser();
    const document = ref({
        title: "",
        sections: [] as { id: number; title: string; content: string }[]
    });

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

    function loadDocument() {
    document.value = {
        title: "User Agreement",
        sections: [
        {
            id: 1,
            title: "Part 1",
            content: "Some bs here, so it looked like I was doing something"
        },
        {
            id: 2,
            title: "Part 2",
            content: "Some more bs"
        },
        {
            id: 3,
            title: "Part 3",
            content: "Some more bs"
        }
        ]
    };
    }

    onMounted(async () => {
        await checkEndpoint();
        loadDocument();
    });

</script>