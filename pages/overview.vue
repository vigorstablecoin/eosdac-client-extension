<template>
  <q-page class="q-pa-md">
    <div class="column gutter-sm q-mt-sm animate-fade">
      <financial-health />
      <backing />
    </div>
  </q-page>
</template>

<script>
import financialHealth from "../components/overview/financial-health";
import backing from "../components/overview/backing";

export default {
  components: {
    financialHealth,
    backing
  },
  data() {
    return {};
  }
};
</script>

<style></style>
