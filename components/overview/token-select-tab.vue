<template>
  <form @submit="_onSubmit">
    <div
      v-if="!tokens || tokens.length === 0"
      class="row justify-center align-center"
    >
      No tokens available
    </div>
    <div v-else class="row justify-center align-center">
      <div class="col-xs-7 col-lg-auto q-mr-md">
        <q-select
          v-model="selectedToken"
          float-label="Select Token"
          radio
          :dark="getIsDark"
          :options="selectOptions"
        />
      </div>
      <div class="col-xs-7 col-lg-auto q-mr-md">
        <q-input
          v-model="amount"
          placeholder="Amount"
          float-label="Amount"
          dense
          type="number"
          :suffix="selectedToken"
          :dark="getIsDark"
          :rules="rulesAmount"
        />
      </div>
      <div class="col-xs-7 col-lg-auto q-mr-md column justify-end">
        <q-btn
          :label="tabTitle"
          type="submit"
          color="primary"
          size="md"
          :disabled="!isValid"
        />
      </div>
    </div>
  </form>
</template>

<script>
import { mapGetters } from "vuex";

export default {
  props: {
    tokens: {
      type: Array,
      default: () => []
    },
    tabTitle: {
      type: String,
      default: ``
    },
    onSubmit: {
      type: Function,
      default: () => null
    }
  },
  components: {},
  data() {
    const selectedToken =
      this.tokens.length > 0 ? this.tokens[0].symbol.symbolCode : ``;

    return {
      selectedToken,
      amount: ``,
      vigorContractName: this.$configFile.configFile.contracts.vigor.name
    };
  },
  computed: {
    ...mapGetters({
      getDacApi: "global/getDacApi",
      getIsDark: "ui/getIsDark",
      getAccountName: "user/getAccountName"
    }),
    selectOptions() {
      return (this.tokens || []).map(
        ({ contract, symbol: { symbolCode } }) => ({
          label: symbolCode,
          value: symbolCode
        })
      );
    },
    isValid() {
      return this.selectedToken && this.amount;
    }
  },
  methods: {
    rulesAmount(val) {
      // rules do not work for some reason in our quasar version
      return [true];
    },
    _onSubmit(event) {
      event.preventDefault();
      event.stopPropagation();

      const token = this.tokens.find(
        ({ symbol: { symbolCode } }) => symbolCode === this.selectedToken
      );
      this.onSubmit({
        amount: this.amount,
        token
      });
    }
  },
  async mounted() {
    await this.$store.dispatch("global/getDacApi");
  },
  watch: {
    tokens() {
      if (!this.selectedToken && this.tokens.length > 0) {
        this.selectedToken = this.tokens[0].symbol.symbolCode;
      }
    }
  }
};
</script>

<style></style>
