<template>
  <div class="tester col backing">
    <div class="bg-bg1 round-borders shadow-4 overflow-hidden q-mb-md">
      <h3
        class="q-px-sm row justify-between items-center bg-primary no-margin"
        style="height:45px"
      >
        <q-icon name="icon-type-2" size="32px" class="text-text2" />
        <span class="q-title text-weight-light">Stablecoin</span>
        <span style="width:32px">&nbsp;</span>
      </h3>
      <div class="q-pa-md row justify-center">
        <div v-if="!getAccountName" class="q-pa-md">
          Please log in to borrow VIGOR or pay off debt.
        </div>
        <div v-else class="q-pa-md">
          <q-tabs
            v-model="tab"
            align="center"
            color="transparent"
            text-color="primary-light"
            animated
            swipeable
            v-if="vigorToken"
          >
            <q-tab
              class="q-py-none"
              slot="title"
              name="borrow"
              label="Borrow"
            />
            <q-tab
              class="q-py-none"
              slot="title"
              name="payoffDebt"
              label="Payoff Debt"
            />

            <q-tab-pane class="q-mt-lg" name="borrow">
              <token-select-tab
                tabTitle="Borrow"
                :onSubmit="
                  args => this.onSubmit({ ...args, tabName: `borrow` })
                "
                :tokens="[vigorToken]"
              />
            </q-tab-pane>
            <q-tab-pane class="q-mt-lg" name="payoffDebt">
              <token-select-tab
                tabTitle="Payoff Debt"
                :onSubmit="
                  args => this.onSubmit({ ...args, tabName: `payoffDebt` })
                "
                :tokens="[vigorToken]"
              />
            </q-tab-pane>
          </q-tabs>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import TokenSelectTab from "./token-select-tab";
import { formatQuantity } from "../../utils/asset";

export default {
  components: {
    TokenSelectTab
  },
  data() {
    return {
      vigorContractName: this.$configFile.configFile.contracts.vigor.name,
      tab: `borrow`
    };
  },
  computed: {
    ...mapGetters({
      getIsDark: "ui/getIsDark",
      getAccountName: "user/getAccountName",
      getAuth: "user/getAuth",
      userInfo: "vigor/getUserInfo",
      availableTokens: "vigor/getAvailableTokens"
    }),
    vigorToken() {
      return this.$store.getters["vigor/getVigorToken"](
        this.$configFile.configFile.contracts.vigor
      );
    }
  },
  methods: {
    async onSubmit({ tabName, amount, token }) {
      try {
        let action = null;
        const quantity = formatQuantity({
          amountString: amount,
          symbol: token.symbol
        });

        switch (tabName) {
          case `borrow`: {
            action = {
              account: this.vigorContractName,
              name: "assetout",
              data: {
                usern: this.getAccountName,
                assetout: quantity,
                memo: `borrow`
              }
            };
            break;
          }
          case `payoffDebt`: {
            action = {
              account: token.contract,
              name: "transfer",
              data: {
                from: this.getAccountName,
                to: this.vigorContractName,
                quantity,
                memo: `payoff debt`
              }
            };
            break;
          }
          default:
            throw new Error(`Invalid transaction choice ${tabName}`);
        }

        action.authorization = [
          { actor: this.getAccountName, permission: this.getAuth }
        ];
        await this.$store.dispatch("user/transact", {
          actions: [action]
        });
        await this.$store.dispatch("vigor/fetchUserInfo");
      } catch (err) {
        console.error(err);
      }
    }
  },
  async mounted() {}
};
</script>

<style lang="stylus" scoped>
@import '~variables'

.backing
  max-width: 100%;
</style>
