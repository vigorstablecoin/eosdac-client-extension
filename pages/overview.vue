<template>
  <q-page class="q-pa-md">
    <div class="column gutter-sm q-mt-sm animate-fade">
      <financial-health />
      <backing />
    </div>
  </q-page>
</template>

<script>
import { mapGetters } from "vuex";
import financialHealth from "../components/overview/financial-health";
import backing from "../components/overview/backing";

export default {
  components: {
    financialHealth,
    backing
  },
  data() {
    return {};
  },
  computed: {
    ...mapGetters({
      getAccountName: "user/getAccountName"
    })
  },
  methods: {
    fetchUserInfo() {
      this.$store.dispatch("vigor/fetchUserInfo");
    }
  },
  async mounted() {
    await this.fetchUserInfo();
  },
  watch: {
    getAccountName: function() {
      this.fetchUserInfo();
    }
  }
};
</script>

<style></style>
