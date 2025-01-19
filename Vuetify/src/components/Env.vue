<template>
  <v-select v-model="selectedFruits" :items="fruits" label="Choose Enviroment" multiple class="custom-container">
    <template v-slot:prepend-item>
      <v-list-item title="Select All" @click="toggle">
        <template v-slot:prepend>
          <v-checkbox-btn :color="likesSomeFruit ? 'indigo-darken-4' : undefined"
            :indeterminate="likesSomeFruit && !likesAllFruit" :model-value="likesSomeFruit"></v-checkbox-btn>
        </template>
      </v-list-item>

      <v-divider class="mt-2"></v-divider>
    </template>


  </v-select>
</template>

<script>
export default {
  data: () => ({
    fruits: [
      'env1',
      'env2',
      'env3',
      'env4',
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
      if (this.likesAllFruit) return 'Holy smokes, someone call the fruit police!'

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
.env-container {
  background-color: #607d8b;
  /* Set your desired background color here */
  border-radius: 15px;
  /* Adjust the border-radius value for smoother corners */
  padding: 15px;
  /* Add some padding to the container */
}
</style>