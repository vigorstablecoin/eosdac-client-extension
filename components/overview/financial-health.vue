<template>
  <div class="tester col">
    <div class="bg-bg1 round-borders shadow-4 overflow-hidden q-mb-md">
      <h3
        class="q-px-sm row justify-between items-center bg-primary no-margin"
        style="height:45px"
      >
        <q-icon name="icon-type-2" size="32px" class="text-text2" />
        <span class="q-title text-weight-light">Financial Health</span>
        <span style="width:32px">&nbsp;</span>
      </h3>
      <div class="relative-position q-pa-md row">
        <div class="col-xs-12 col-md-6 q-px-lg column align-center">
          <span v-if="getAccountName" class="text-center text-bold">
            Account Information
          </span>
          <span v-else class="text-center text-bold">
            Log in to view user stats
          </span>
          <div class="q-pa-sm q-mb-sm">
            <table-view
              v-if="financialHealthUser"
              class="col-grow"
              :json="financialHealthUser"
            />
            <div v-else class="q-mt-lg text-center">No user data found</div>
          </div>
        </div>
        <div class="col-xs-12 col-md-6 q-px-lg column align-center">
          <span class="text-center text-bold">Global Community</span>
          <div class="bg-bg3 q-pa-sm q-mb-sm">
            <table-view class="col-grow" :json="financialHealthGlobal" />
          </div>
        </div>

        <q-btn
          icon="refresh"
          @click="refresh"
          flat
          :loading="loading"
          title="Reload data"
          class="absolute-top-right"
        />
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import tableView from "../table-view";

export default {
  components: {
    tableView
  },
  data() {
    return {
      vigorContractName: this.$configFile.configFile.contracts.vigor.name,
      financialHealthGlobal: null,
      loading: false
    };
  },
  computed: {
    ...mapGetters({
      getDacApi: "global/getDacApi",
      getIsDark: "ui/getIsDark",
      getAccountName: "user/getAccountName",
      financialHealthUser: "vigor/getUserInfo"
    })
  },
  methods: {
    async getGlobalFinancialHealth() {
      this.loading = true;

      try {
        const globalRes = await this.getDacApi.eos.get_table_rows({
          json: true,
          code: this.vigorContractName,
          scope: this.vigorContractName,
          table: "globals",
          limit: 1
        });

        this.financialHealthGlobal = globalRes.rows[0];
      } catch (err) {
        console.error(err);
      } finally {
        this.loading = false;
      }
    },
    async refresh() {
      try {
        await Promise.all([
          this.$store.dispatch("vigor/fetchUserInfo"),
          this.getGlobalFinancialHealth()
        ]);
      } catch (err) {
        console.error(err);
      }
    }
  },
  async mounted() {
    await this.$store.dispatch("global/getDacApi");
    await this.getGlobalFinancialHealth();
  }
};
</script>

<style></style>
