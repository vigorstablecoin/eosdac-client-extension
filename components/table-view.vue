<template>
  <q-list no-border highlight multiline :dark="getIsDark" class="list">
    <q-item v-for="(value, key) in json" :key="key" class="q-py-sm">
      <q-item-side color="primary-light pointer" top>
        <div
          v-if="displayValue(key).title"
          class="itemKey uppercase text-weight-medium"
        >
          {{ displayValue(key).title }}
        </div>
        <div v-else class="itemKey uppercase text-weight-medium">
          {{ displayValue(key) }}
        </div>
        <q-tooltip v-if="displayValue(key).tooltip">{{
          displayValue(key).tooltip
        }}</q-tooltip>
      </q-item-side>
      <q-item-main class="itemValue">
          <q-list
            v-if="Array.isArray(value) && value.length > 0"
            dense
            no-border
            highlight
            :dark="getIsDark"
            class="no-padding"
          >
          <q-item v-for="childVal in value" :key="childVal" class="no-padding">
            <q-item-main>{{ childVal }}</q-item-main>
          </q-item>
        </q-list>
        <span v-else class="text-weight-bold">{{
          formatValue(key, value)
        }}</span>
      </q-item-main>
    </q-item>
  </q-list>
</template>

<script>
import { mapGetters } from "vuex";

export default {
  name: "tableView",
  props: {
    json: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {};
  },
  computed: {
    ...mapGetters({ getIsDark: "ui/getIsDark" })
  },
  methods: {
    formatValue(key, val) {
      if (key === "lastupdate") {
        let lastDate = new Date(val);
        return lastDate.toUTCString();
      }
      // if string or number is a float, round decimals only if necessary
      if (!isNaN(val) && val.toString().indexOf(".") !== -1) {
        // adds dollar or percent sign
        if (
          key === "stresscol" ||
          key === "pcts" ||
          key === "istresscol" ||
          key === "stressins"
        ) {
          return +(+val).toFixed(4) * 100 + " %";
        } else if (
          key === "svalueofcol" ||
          key === "svalueofcole" ||
          key === "valueofcol" ||
          key === "valueofins" ||
          key === "svalueofins"
        ) {
          return "$" + (+val).toFixed(2);
        } else if (key === "tesprice") {
          return "$" + (+val).toFixed(4);
        } else {
          return +(+val).toFixed(6);
        }
      }

      return val;
    },
    displayValue(key) {
      switch (key) {
        case "usern":
          return {
            title: "Username"
          };
        case "valueofcol":
          return {
            title: "Value of Collateral",
            tooltip:
              "Dollar value of total portfolio of borrowers crypto collateral assets"
          };
        case "valueofins":
          return {
            title: "Value of Insurance",
            tooltip:
              "Dollar value of total portfolio of insurance crypto assets"
          };
        case "tesprice":
          return {
            title: "TES Price",
            tooltip:
              "Annualized rate borrowers pay in periodic premiums to insure their collateral"
          };
        case "pcts":
          return {
            title: "Percent of Contribution",
            tooltip:
              "Percent contribution to solvency (weighted marginal contribution to risk (solvency) rescaled by sum of that"
          };
        case "volcol":
          return {
            title: "Volatility of Collateral",
            tooltip: "Volatility of the user collateral portfolio"
          };
        case "stresscol":
          return {
            title: "Stress Collateral Loss",
            tooltip:
              "Model suggested percentage loss that the user collateral portfolio would experience in a stress event"
          };
        case "istresscol":
          return {
            title: "Implied Stress Collateral Loss",
            tooltip:
              "Market determined implied percentage loss that the user collateral portfolio would experience in a stress event"
          };
        case "svalueofcol":
          return {
            title: "Stress Value of Collateral",
            tooltip:
              "Model suggested dollar value of the user collateral portfolio in a stress event"
          };
        case "svalueofcole":
          return {
            title: "Insufficient Stress Collateral",
            tooltip:
              "Model suggested dollar amount of insufficient collateral of a user loan in a stressed market"
          };
        case "svalueofins":
          return {
            title: "Suggested Insurance Value",
            tooltip:
              "Model suggested dollar value of the total insurance asset portfolio in a stress event"
          };
        case "stressins":
          return {
            title: "Stress Insurance",
            tooltip:
              "Model suggested percentage loss that the total insurance asset portfolio would experience in a stress event"
          };
        case "inreserve":
          return {
            title: "In reserve"
          };
        case "totaldebt":
          return {
            title: "Total Debt"
          };
        case "feespaid":
          return {
            title: "Feeds Paid"
          };
        case "creditscore":
          return {
            title: "Credit Score"
          };
        case "lastupdate":
          return {
            title: "Last Update"
          };
        case "latepays":
          return {
            title: "Late Pays"
          };
        case "scale":
          return {
            title: "Scale",
            tooltip:
              "TES pricing model parameters are scaled to drive risk (solvency) to a target set by custodians."
          };
        case "solvency":
          return {
            title: "Solvency",
            tooltip:
              "Solvency, represents capital adequacy to back the stablecoin"
          };
      }
      return key;
    }
  }
};
</script>

<style lang="stylus" scoped>
@import '~variables'

.list
  max-height: 520px;
  overflow-y: scroll;
  overscroll-behavior: contain;
  /* For firefox: https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Scrollbars */
  scrollbar-color: var(--q-color-dark) var(--q-color-bg2);
  scrollbar-width: thin;
  scrollbar-height 90%;

  &::-webkit-scrollbar
    width: 10px;

  &::-webkit-scrollbar-track
    background: var(--q-color-bg2);

  &::-webkit-scrollbar-thumb
    background: var(--q-color-dark);

.itemKey
  width: 200px;

.itemValue
  margin-left: 150px
</style>
