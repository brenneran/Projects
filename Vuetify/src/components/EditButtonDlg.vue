<template>
<v-dialog
  transition="dialog-top-transition"
  width="40%"
>
<template v-slot:activator="{ props }">
  <v-btn density="compact" icon="mdi-table-edit" v-bind="props"></v-btn>

</template>
<template v-slot:default="{ isActive }">
  <v-card>
    <v-toolbar
      title="Edit Additional tags">
      <v-card-actions class="justify-end">
        <v-btn
          density="compact"
          icon="mdi-close"
          @click="isActive.value = false"
        ></v-btn>
      </v-card-actions>
    </v-toolbar>
    <v-card-text>
    <v-table>
      <thead>
      <tr>
      <th class="text-left">Tag Name</th>
      <th class="text-left">Value</th>
      <th class="text-left">Action</th>
      </tr>
      </thead>
      <tbody>
      <tr
        v-for="(item, index) in aws_data"
        :key="item.id"
      >
        <td><input type="text" v-model="item.tag_name"></td>
        <td><input type="text" v-model="item.tag_value"></td>
        <td><v-btn density="compact" icon="mdi-delete" @click="removeRow(index)"> </v-btn></td>
      </tr>
      </tbody>
    </v-table>
    </v-card-text>
    <v-card-actions class="justify-lg-start">
      <v-btn variant="elevated" style="margin-left: 30px" @click="addRow"
      >Add new</v-btn>
    </v-card-actions>
  </v-card>
</template>
</v-dialog>
</template>
<script setup>
</script>
<script>
export default {
  props: {
    aws_data: Array,
  },
  methods: {
    addRow() {
      // Add a new empty row to aws_data
      this.$props.aws_data.push({ tag_name: '', tag_value: '' });
    },
    removeRow(index) {
      // Remove a row from aws_data by index
      console.debug(index)
      this.$props.aws_data.splice(index, 1);
    },
  },
};
</script>
