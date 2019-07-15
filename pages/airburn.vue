<template>
  <!-- https://jungle.eosq.app/account/vigairburn12/tables?lowerBound=&scope=vigairburn12&tableName=payment -->
  <q-page class="q-pa-md">
    <div class="bg-bg1 round-borders q-pa-md shadow-4">
      The VIG tokens are distributed via an AirBurn model. When you transfer EOS
      in to the contract ({{ contractname }}) the EOS will be burned and you'll
      be able to claim your proportional VIG amount at the next round. Each
      round
      <span v-if="contractSettings">{{
        contractSettings.quota_per_cycle.quantity
      }}</span>
      will be proportional divided based on the amount of EOS you and other
      people have burned.
    </div>
    <div v-if="contractSettings">
      <div>
        Round: {{ getCurrentCycleStats.current_cycle_number }} Rounds Left:
        {{ getCurrentCycleStats.rounds_left }}
      </div>
      <div>Total Burned {{ getTotalPayInForCurrentCycle }} EOS</div>
    </div>
    <countdown
      v-if="contractSettings"
      :time="getCurrentCycleStats.ms_left"
      :emit-events="true"
      @end="startNewCycle"
    >
      <template slot-scope="props">
        <div>Round ends in:</div>
        <div class="q-caption text-weight-light text-text2">
          <span v-if="props.days">{{ props.days }} days, </span>
          <span v-if="props.hours">{{ props.hours }} hours, </span>
          <span v-if="props.minutes">{{ props.minutes }} minutes, </span>
          <span>{{ props.seconds }} seconds</span>
        </div>
      </template>
    </countdown>

    <!-- <pre>{{ contractSettings }}</pre> -->
    <q-input
      :dark="getIsDark"
      v-model="transferamount"
      color="primary-light"
      stack-label="Amount EOS"
    />
    <q-btn @click="burnEos" label="send" color="primary" />
    <q-btn
      @click="claimPayments"
      label="claim"
      color="primary"
      v-if="myclaimables.length"
    />
    <div class="row gutter-md">
      <div class="col-xs-12 col-md-6">
        all cycles
        <pre>{{ cycles }}</pre>
      </div>
      <div class="col-xs-12 col-md-6">
        my claims
        <pre>{{ myclaimables }}</pre>
      </div>
    </div>
  </q-page>
</template>

<script>
import { mapGetters } from "vuex";
import countdown from "@chenfengyuan/vue-countdown";
export default {
  name: "airburn",
  components: {
    countdown
  },
  data() {
    return {
      contractname: this.$configFile.configFile.contracts.airburn.name,
      contractSettings: false,
      cycles: [],
      myclaimables: [],
      transferamount: "",
      NOW: new Date().getTime()
    };
  },
  computed: {
    ...mapGetters({
      getDacApi: "global/getDacApi",
      getIsDark: "ui/getIsDark",
      getAccountName: "user/getAccountName"
    }),

    getCurrentCycleStats() {
      if (!this.contractSettings) return 0;

      let start_burn =
        (this.contractSettings.start_ts -
          (this.contractSettings.start_ts % 1000)) /
        1000;

      let cycle_length = this.contractSettings.seconds_per_cycle * 1000;

      let current_cycle_num = Math.trunc(
        (this.NOW - start_burn) / cycle_length
      );
      return {
        current_cycle_number: current_cycle_num,
        ms_left: cycle_length - ((this.NOW - start_burn) % cycle_length),
        rounds_left: this.contractSettings.cycles - current_cycle_num
      };
    },
    getTotalPayInForCurrentCycle() {
      let totalEOSIn = 0;
      if (this.getCurrentCycleStats) {
        let cycleNum = this.getCurrentCycleStats.current_cycle_number;
        let cycle = this.cycles.find(c => c.number == cycleNum);

        if (cycle) {
          totalEOSIn = cycle.total_payins.split(" ")[0];
        }
      }
      return totalEOSIn;
    }
  },
  methods: {
    startNewCycle() {
      this.NOW = new Date().getTime();
      this.getClaimablePayments();
    },
    //read data
    async getSettings() {
      let res = await this.getDacApi.eos
        .get_table_rows({
          json: true,
          code: this.contractname,
          scope: this.contractname,
          table: "settings",
          limit: 1
        })
        .catch(e => {
          console.log(e);
          return false;
        });
      if (res) {
        this.contractSettings = res.rows[0];
      }
    },
    async getCycles() {
      let res = await this.getDacApi.eos
        .get_table_rows({
          json: true,
          code: this.contractname,
          scope: this.contractname,
          table: "cycle",
          //   upper_bound: 1,
          reverse: true,
          limit: 10
        })
        .catch(e => {
          console.log(e);
          return false;
        });
      if (res) {
        this.cycles = res.rows;
      }
    },
    async getClaimablePayments() {
      let account = this.getAccountName;
      let res = await this.getDacApi.eos
        .get_table_rows({
          json: true,
          code: this.contractname,
          scope: this.contractname,
          table: "payment",
          lower_bound: account, //testpieces12
          upper_bound: account, //testpieces12
          index_position: 2,
          key_type: "name",
          limit: -1
        })
        .catch(e => {
          console.log(e);
          return false;
        });
      if (res) {
        this.myclaimables = res.rows;
      }
    },
    async getPayInPerCycle() {
      let cycle = 18;
      let res = await this.getDacApi.eos
        .get_table_rows({
          json: true,
          code: this.contractname,
          scope: this.contractname,
          table: "cycle",
          lower_bound: cycle,
          upper_bound: cycle,
          limit: -1
        })
        .catch(e => false);

      console.log("cyclepayins", res);
    },
    //actions
    async claimPayments() {
      let action = [
        {
          account: this.contractname,
          name: "claim",
          data: {
            payer: this.getAccountName
          }
        }
      ];
      let result = await this.$store.dispatch("user/transact", {
        actions: action
      });
      if (result) {
        this.getClaimablePayments();
        console.log(result);
      }
    },
    async burnEos() {
      let action = [
        {
          account: "eosio.token",
          name: "transfer",
          data: {
            from: this.getAccountName,
            to: this.contractname,
            quantity: this.transferamount,
            memo: ""
          }
        }
      ];
      let result = await this.$store.dispatch("user/transact", {
        actions: action
      });
      if (result) {
        console.log(result);
        await this.getCycles();
        await this.getPayInPerCycle();
      }
    }
  },
  async mounted() {
    await this.getSettings();
    await this.getCycles();
    this.getClaimablePayments();
    this.getPayInPerCycle();
  }
};
</script>

<style></style>
