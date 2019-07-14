<template>
  <div>
    <q-item to="/vigorapp">
      <q-item-side icon="mdi-exit-to-app" color="text2" />
      <q-item-main label="VIGOR APP" class="text-text1" />
    </q-item>
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import { openURL } from "quasar";
export default {
  name: "menuExtension",
  data() {
    return {};
  },
  methods: {
    openURL
  },
  computed: {
    ...mapGetters({
      getSettingByName: "user/getSettingByName"
    })
  }
};
</script>

<style></style>
