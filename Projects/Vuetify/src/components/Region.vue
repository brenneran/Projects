<template>
    <v-select v-model="selected" label="Choose Region" :no-data-text="no_results_text" >
        <template v-slot:prepend-item class="invisible">
            <v-list-item @click="toggle" class="invisible"> 
                <AppFilter />
            </v-list-item>
        </template>
    </v-select>
</template>

<script setup>
import AppFilter from '@/components/AppFilter.vue'

// Define your data
const selected = null; // or set a default value
const no_results_text = ''; // Set your custom message
</script>
