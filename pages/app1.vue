<template>
  <q-page class="q-pa-md">
    <div>here will live the vigor app</div>
  </q-page>
</template>

<script>
import { mapGetters } from "vuex";
export default {
  name: "test",
  computed: {
    ...mapGetters({
      getAccountName: "user/getAccountName"
    })
  }
};
</script>

<style></style>
