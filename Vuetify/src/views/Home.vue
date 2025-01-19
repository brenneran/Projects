<template>
    <v-container class="main-container">
      <v-row no-gutters>
        <v-col order="2" class="vcol">
          <Environments />
        </v-col>
        <v-col order="3" class="vcol">
          <Region />
        </v-col>
        <v-col order="1" class="vcol">
          <Search />
        </v-col>
      </v-row>
      <v-row no-gutters>
        <Boards/>
      </v-row>
    </v-container>
</template>

<script setup>
  import Region from '@/components/Region.vue'
  import Search from '@/components/Search.vue'
  import Environments from "@/components/Environments.vue";
  import Boards from "@/components/Boards.vue";
</script>

<style>
.main-container {
  background-color: #607d8b; /* Set your desired background color here */
  border-radius: 7px; /* Adjust the border-radius value for smoother corners */
  padding: 15px; /* Add some padding to the container */
}
.vcol {
    border-radius: 4px; /* Adjust the border-radius value for smoother corners */
    margin-left: 10px;
    margin-bottom: 5px;
    background-color: rgb(208, 226, 243);
  }
</style>
