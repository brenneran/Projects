<template>
  <v-card max-width="500px">
    <v-card-text>
      <v-chip-group v-model="amenities" multiple>
        <v-chip filter variant="outlined">
          us-west-1
        </v-chip>
        <v-chip filter variant="outlined">
          us-west-2
        </v-chip>
        <v-chip filter variant="outlined">
          eu-central-1
        </v-chip>
        <v-chip filter variant="outlined">
          cn-north-1
        </v-chip>
        <v-chip filter variant="outlined">
          ap-northeast-1
        </v-chip>
      </v-chip-group>
    </v-card-text>
  </v-card>
</template>

<script>
export default {
  data: () => ({
    amenities: [1, 5],
  }),
}
</script>
<style>
.invisible {
  display: none;
}
</style>