<template>
  <q-page class="q-pa-md">
    <div class="row gutter-sm q-mt-sm animate-fade" v-if="loadingPage">
      <div class="tester col">
        <div class="bg-bg1 round-borders shadow-4 overflow-hidden q-mb-md">
          <div
            class="q-px-sm row justify-between items-center bg-primary"
            style="height:45px"
          >
            <q-icon name="icon-type-2" size="32px" class="text-text2" />
            <span class="q-title text-weight-light">Financial Health</span>
            <span style="width:32px">&nbsp;</span>
          </div>
          <div class="relative-position q-pa-md row">
            <div class="col-xs-12 col-md-6 q-px-lg column align-center">
              <div class="q-pa-sm q-mb-sm">
                <table-view
                  v-if="financialHealthUser"
                  class="col-grow"
                  :json="financialHealthUser"
                />
                <div v-else class="q-mt-lg text-center">No user data found</div>
              </div>
              <span class="text-center text-bold">{{
                getAccountName || `Log in to view user stats`
              }}</span>
            </div>
            <div class="col-xs-12 col-md-6 q-px-lg column align-center">
              <div class="bg-bg3 q-pa-sm q-mb-sm">
                <table-view class="col-grow" :json="financialHealthGlobal" />
              </div>
              <span class="text-center text-bold">Global Community</span>
            </div>

            <q-btn
              icon="refresh"
              @click="getFinancialHealth"
              flat
              :loading="loadingFinancialHealth"
              title="Reload data"
              class="absolute-top-right"
            />
          </div>
        </div>
      </div>
    </div>
  </q-page>
</template>

<script>
import { mapGetters } from "vuex";
import tableView from "../components/table-view";
export default {
  components: {
    tableView
  },
  data() {
    return {
      vigorContractName: this.$configFile.configFile.contracts.vigor.name,
      financialHealthUser: null,
      financialHealthGlobal: null,
      loadingPage: false,
      loadingFinancialHealth: false
    };
  },
  computed: {
    ...mapGetters({
      getDacApi: "global/getDacApi",
      getIsDark: "ui/getIsDark",
      getAccountName: "user/getAccountName"
    })
  },
  methods: {
    async getFinancialHealth() {
      this.loadingFinancialHealth = true;
      const userName = this.getAccountName;

      try {
        const [globalRes, userRes] = await Promise.all([
          this.getDacApi.eos.get_table_rows({
            json: true,
            code: this.vigorContractName,
            scope: this.vigorContractName,
            table: "globals",
            limit: 1
          }),
          this.getDacApi.eos.get_table_rows({
            json: true,
            code: this.vigorContractName,
            scope: this.vigorContractName,
            table: "user",
            key_type: `name`,
            index_position: 1,
            lower_bound: `${userName}`,
            upper_bound: `${userName}`,
            limit: 1
          })
        ]);

        this.financialHealthGlobal = globalRes.rows[0];
        this.financialHealthUser = userRes.rows[0];
      } catch (err) {
        console.error(err);
      } finally {
        this.loadingFinancialHealth = false;
      }
    }
  },
  async mounted() {
    await this.$store.dispatch("global/getDacApi");
    await this.getFinancialHealth();
    this.loadingPage = true;
  }
};
</script>

<style></style>
