<template>
    <v-select v-model="selectedFruits" :items="fruits" label="Choose Component" multiple>
        <template v-slot:prepend-item class="app-container">
            <v-list-item title="Select All" @click="toggle">
                <template v-slot:prepend>
                    <v-checkbox-btn :color="likesSomeFruit ? 'indigo-darken-4' : undefined"
                        :indeterminate="likesSomeFruit && !likesAllFruit" :model-value="likesSomeFruit"></v-checkbox-btn>
                </template>
            </v-list-item>

            <v-divider class="mt-2"></v-divider>
        </template>

        <template v-slot:append-item>
            <v-divider class="mb-2"></v-divider>

            <v-list-item :subtitle="subtitle" :title="title" disabled>
                <template v-slot:prepend>
                    <v-avatar icon="mdi-cursor-pointer" color="primary">
                        mdi-food-apple
                    </v-avatar>
                </template>
            </v-list-item>
        </template>
    </v-select>
</template>
  
<script>
export default {
    data: () => ({
        fruits: [
            'Component1',
            'Component2',
            'Component3',
            'Component4',
            'Component5',
            'Component6'
        ],
        selectedFruits: [],
    }),

    computed: {
        likesAllFruit() {
            return this.selectedFruits.length === this.fruits.length
        },
        likesSomeFruit() {
            return this.selectedFruits.length > 0
        },
        title() {
            if (this.likesAllFruit) return 'Holy smokes, someone call the iTero police!'

            if (this.likesSomeFruit) return 'Components Selected'

            return 'No selected component'
        },
        subtitle() {
            if (this.likesAllFruit) return undefined

            if (this.likesSomeFruit) return this.selectedFruits.length

            return 'Go ahead, make a selection above!'
        },
    },

    methods: {
        toggle() {
            if (this.likesAllFruit) {
                this.selectedFruits = []
            } else {
                this.selectedFruits = this.fruits.slice()
            }
        },
    },
}
</script>
<style>
.app-container {
    border-radius: 25px;
    /* Adjust the border-radius value for smoother corners */
    padding: 15px;
    /* Add some padding to the container */
}
</style>