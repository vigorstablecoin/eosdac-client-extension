<template>
  <!-- https://jungle.eosq.app/account/vigairburn12/tables?lowerBound=&scope=vigairburn12&tableName=payment -->
  <q-page class="q-pa-md">
    <pre>{{ contractSettings }}</pre>
    <q-input
      :dark="getIsDark"
      v-model="transferamount"
      color="primary-light"
      stack-label="Amount EOS"
    />
    <q-btn @click="burnEos" label="send" color="primary" />
    <q-btn @click="getClaimablePayments" label="test" />
    <q-btn @click="claimPayments" label="claim" color="primary" />
    <pre>{{ cycles }}</pre>
  </q-page>
</template>

<script>
import { mapGetters } from "vuex";
export default {
  name: "airburn",
  data() {
    return {
      contractSettings: false,
      cycles: false,
      transferamount: ""
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
    //read data
    async getSettings() {
      let res = await this.getDacApi.eos
        .get_table_rows({
          json: true,
          code: "vigairburn12",
          scope: "vigairburn12",
          table: "settings",
          limit: 1
        })
        .catch(e => {
          console.log(e);
          return false;
        });
      if (res) {
        this.contractSettings = res;
      }
    },
    async getCycles() {
      let res = await this.getDacApi.eos
        .get_table_rows({
          json: true,
          code: "vigairburn12",
          scope: "vigairburn12",
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
        this.cycles = res;
      }
    },
    async getClaimablePayments() {
      let account = this.getAccountName;
      let res = await this.getDacApi.eos
        .get_table_rows({
          json: true,
          code: "vigairburn12",
          scope: "vigairburn12",
          table: "payment",
          lower_bound: account, //testpieces12
          upper_bound: account, //testpieces12
          index_position: 3,
          key_type: "name",
          limit: -1
        })
        .catch(e => {
          console.log(e);
          return false;
        });

      console.log("claimables", res);
    },
    async getPayInPerCycle() {
      let cycle = 18;
      let res = await this.getDacApi.eos
        .get_table_rows({
          json: true,
          code: "vigairburn12",
          scope: "vigairburn12",
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
          account: "vigairburn12",
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
            to: "vigairburn12",
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
      }
    }
  },
  mounted() {
    this.getSettings();
    this.getClaimablePayments();
    this.getPayInPerCycle();
    this.getCycles();
  }
};
</script>

<style></style>
