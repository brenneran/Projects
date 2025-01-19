<template>
  <v-table>
    <thead>
    <tr>
      <th class="text-left">
        Account
      </th>
      <th class="text-left">
        Region
      </th>
      <th class="text-left">
        id
      </th>
      <th class="text-left">
        Role
      </th>
      <th class="text-left">
        Environment
      </th>
      <th class="text-left">
        Owner
      </th>
      <th class="text-left">
        Name
      </th>
      <th class="text-left">
        Requestor
      </th>
      <th class="text-left">
        Other tags
      </th>
    </tr>
    </thead>
    <tbody>
    <tr
      v-for="item in aws_resources"
      :key="item.name"
    >
      <td>{{ item.account }}</td>
      <td>{{ item.region }}</td>
      <td>{{ item.id }}</td>
      <td>{{ item.role }}</td>
      <td>{{ item.environment }}</td>
      <td>{{ item.owner }}</td>
      <td>{{ item.name }}</td>
      <td>{{ item.requestor }}</td>
      <td><EditButtonDlg :aws_data="item.other_tags"/></td>
    </tr>
    </tbody>
  </v-table>
</template>

<script setup>
import EditButtonDlg from "@/components/EditButtonDlg.vue";
</script>
<script>
export default {
  data () {
    return {
      aws_resources: [
        {
          account: '440130807111',
          region: "us-west-2",
          id: "billingms-us-west-2-ct3-0",
          role: "billingms/db/aurora-postgres/instance",
          environment: "ct3",
          owner: "your-project/itops",
          name: "your-project-rds-devops-team",
          requestor: "your-requestor",
          other_tags: [
            {tag_name: "tag1", tag_value: "val1"},
            {tag_name: "tag1", tag_value: "val1"},
            {tag_name: "tag1", tag_value: "val1"},
          ],
        },
        {
          account: '440130807111',
          region: "us-west-2",
          id: "billingms-us-west-2-ct3-0",
          role: "billingms/db/aurora-postgres/instance",
          environment: "ct3",
          owner: "your-project/itops",
          name: "your-project-rds-devops-team",
          requestor: "your-requestor",
          other_tags: [
            {tag_name: "tag1", tag_value: "val1"},
            {tag_name: "tag1", tag_value: "val1"},
            {tag_name: "tag1", tag_value: "val1"},
          ],
        },
        {
          account: '440130807111',
          region: "us-west-2",
          id: "billingms-us-west-2-ct3-0",
          role: "billingms/db/aurora-postgres/instance",
          environment: "ct3",
          owner: "your-project/itops",
          name: "your-project-rds-devops-team",
          requestor: "your-requestor",
          other_tags: [
            {tag_name: "tag1", tag_value: "val1"},
            {tag_name: "tag1", tag_value: "val1"},
            {tag_name: "tag1", tag_value: "val1"},
          ],
        },
        {
          account: '440130807111',
          region: "us-west-2",
          id: "billingms-us-west-2-ct3-0",
          role: "billingms/db/aurora-postgres/instance",
          environment: "ct3",
          owner: "your-project/itops",
          name: "your-project-rds-devops-team",
          requestor: "your-requestor",
          other_tags: [
            {tag_name: "tag1", tag_value: "val1"},
            {tag_name: "tag1", tag_value: "val1"},
            {tag_name: "tag1", tag_value: "val1"},
          ],
        },
        {
          account: '440130807111',
          region: "us-west-2",
          id: "billingms-us-west-2-ct3-0",
          role: "billingms/db/aurora-postgres/instance",
          environment: "ct3",
          owner: "your-project/itops",
          name: "your-project-rds-devops-team",
          requestor: "your-requestor",
          other_tags: [
            {tag_name: "tag1", tag_value: "val1"},
            {tag_name: "tag1", tag_value: "val1"},
            {tag_name: "tag1", tag_value: "val1"},
          ],
        },
        {
          account: '440130807111',
          region: "us-west-2",
          id: "billingms-us-west-2-ct3-0",
          role: "billingms/db/aurora-postgres/instance",
          environment: "ct3",
          owner: "your-project/itops",
          name: "your-project-rds-devops-team",
          requestor: "your-requestor",
          other_tags: [
            {tag_name: "tag1", tag_value: "val1"},
            {tag_name: "tag1", tag_value: "val1"},
            {tag_name: "tag1", tag_value: "val1"},
          ],
        },
        {
          account: '440130807111',
          region: "us-west-2",
          id: "billingms-us-west-2-ct3-0",
          role: "billingms/db/aurora-postgres/instance",
          environment: "ct3",
          owner: "your-project/itops",
          name: "your-project-rds-devops-team",
          requestor: "your-requestor",
          other_tags: [
            {tag_name: "tag1", tag_value: "val1"},
            {tag_name: "tag1", tag_value: "val1"},
            {tag_name: "tag1", tag_value: "val1"},
          ],
        },
        {
          account: '440130807111',
          region: "us-west-2",
          id: "billingms-us-west-2-ct3-0",
          role: "billingms/db/aurora-postgres/instance",
          environment: "ct3",
          owner: "your-project/itops",
          name: "your-project-rds-devops-team",
          requestor: "your-requestor",
          other_tags: [
            {tag_name: "tag1", tag_value: "val1"},
            {tag_name: "tag1", tag_value: "val1"},
            {tag_name: "tag1", tag_value: "val1"},
          ],
        },
      ],
    }
  },
}
</script>
