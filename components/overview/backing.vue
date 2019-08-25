<template>
  <div class="tester col backing">
    <div class="bg-bg1 round-borders shadow-4 overflow-hidden q-mb-md">
      <h3
        class="q-px-sm row justify-between items-center bg-primary no-margin"
        style="height:45px"
      >
        <q-icon name="icon-type-2" size="32px" class="text-text2" />
        <span class="q-title text-weight-light">Backing</span>
        <span style="width:32px">&nbsp;</span>
      </h3>
      <div class="q-pa-md row justify-center">
        <div v-if="!getAccountName" class="q-pa-md">
          Please log in to deposit or withdraw collateral/insurance.
        </div>
        <div v-else class="q-pa-md">
          <q-tabs
            v-model="tab"
            align="center"
            color="transparent"
            text-color="primary-light"
            animated
            swipeable
          >
            <q-tab
              class="q-py-none"
              slot="title"
              name="depositCollateral"
              label="Deposit Collateral"
            />
            <q-tab
              class="q-py-none"
              slot="title"
              name="withdrawCollateral"
              label="Withdraw Collateral"
            />
            <q-tab
              class="q-py-none"
              slot="title"
              name="depositInsurance"
              label="Deposit Insurance"
            />
            <q-tab
              class="q-py-none"
              slot="title"
              name="withdrawInsurance"
              label="Withdraw Insurance"
            />

            <q-tab-pane class="q-mt-lg" name="depositCollateral">
              <backing-tab
                tabTitle="Deposit Collateral"
                :onSubmit="
                  args =>
                    this.onSubmit({ ...args, tabName: `depositCollateral` })
                "
                :tokens="availableTokens"
              />
            </q-tab-pane>
            <q-tab-pane class="q-mt-lg" name="withdrawCollateral">
              <backing-tab
                tabTitle="Withdraw Collateral"
                :onSubmit="
                  args =>
                    this.onSubmit({ ...args, tabName: `withdrawCollateral` })
                "
                :tokens="availableWithdrawCollateralTokens"
              />
            </q-tab-pane>

            <q-tab-pane class="q-mt-lg" name="depositInsurance"
              ><backing-tab
                tabTitle="Deposit Insurance"
                :onSubmit="
                  args =>
                    this.onSubmit({ ...args, tabName: `depositInsurance` })
                "
                :tokens="availableTokens"
            /></q-tab-pane>
            <q-tab-pane class="q-mt-lg" name="withdrawInsurance"
              ><backing-tab
                tabTitle="Withdraw Insurance"
                :onSubmit="
                  args =>
                    this.onSubmit({ ...args, tabName: `withdrawInsurance` })
                "
                :tokens="availableWithdrawInsuranceTokens"
            /></q-tab-pane>
          </q-tabs>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import BackingTab from "./backing-tab";

const formatQuantity = ({ amountString, symbol }) => {
  const { precision, symbolCode } = symbol;
  let [pre, decimals] = String(amountString).split(`.`);

  if (!pre) pre = `0`;
  // pad with 0s to precision length, or cut off too much precision
  decimals = ((decimals || ``) + `0`.repeat(precision)).slice(0, precision);

  let result = `${pre}.${decimals}`;
  result = `${result} ${symbolCode}`;
  return result;
};

export default {
  components: {
    BackingTab
  },
  data() {
    return {
      vigorContractName: this.$configFile.configFile.contracts.vigor.name,
      loading: false,
      availableTokens: [],
      userInfo: null,
      tab: `depositCollateral`
    };
  },
  computed: {
    ...mapGetters({
      getDacApi: "global/getDacApi",
      getIsDark: "ui/getIsDark",
      getAccountName: "user/getAccountName",
      getAuth: "user/getAuth"
    }),
    availableWithdrawCollateralTokens() {
      if (
        !this.userInfo ||
        !Array.isArray(this.userInfo.collateral) ||
        !Array.isArray(this.availableTokens)
      )
        return [];

      return this.availableTokens.filter(
        ({ contract, symbol: { symbolCode } }) => {
          return this.userInfo.collateral.some(balance => {
            const [, _symbolCode] = balance.split(` `);
            return symbolCode === _symbolCode;
          });
        }
      );
    },
    availableWithdrawInsuranceTokens() {
      if (
        !this.userInfo ||
        !Array.isArray(this.userInfo.insurance) ||
        !Array.isArray(this.availableTokens)
      )
        return [];

      return this.availableTokens.filter(
        ({ contract, symbol: { symbolCode } }) => {
          return this.userInfo.insurance.some(balance => {
            const [, _symbolCode] = balance.split(` `);
            return symbolCode === _symbolCode;
          });
        }
      );
    }
  },
  methods: {
    async getAvailableDepositTokens() {
      // TODO: fetch these extended assets from a list somewhere
      // right now hard-coded in vigor's apply function
      // https://github.com/vigorstablecoin/vigor/blob/dfe964029831ed9ece2f5e929ddbb1a6a1332c53/contracts/vigor/src/vigor.cpp#L896
      this.availableTokens = [
        {
          contract: `eosio.token`,
          symbol: {
            symbolCode: `EOS`,
            precision: 4
          }
        },
        {
          contract: `vigtokenz111`,
          symbol: {
            symbolCode: `VIG`,
            precision: 4
          }
        },
        {
          contract: `dummytokensx`,
          symbol: {
            symbolCode: `IQ`,
            precision: 3
          }
        }
      ];
    },
    async getUserInfo() {
      const userName = this.getAccountName;

      try {
        const userInfo = await this.getDacApi.eos.get_table_rows({
          json: true,
          code: this.vigorContractName,
          scope: this.vigorContractName,
          table: "user",
          key_type: `name`,
          index_position: 1,
          lower_bound: `${userName}`,
          upper_bound: `${userName}`,
          limit: 1
        });

        this.userInfo = userInfo.rows[0];
      } catch (err) {
        console.error(err);
      } finally {
        this.loading = false;
      }
    },
    async onSubmit({ tabName, amount, token }) {
      try {
        let action = null;
        const quantity = formatQuantity({
          amountString: amount,
          symbol: token.symbol
        });

        switch (tabName) {
          case `withdrawCollateral`:
          case `withdrawInsurance`: {
            action = {
              account: this.vigorContractName,
              name: "assetout",
              data: {
                usern: this.getAccountName,
                assetout: quantity,
                memo:
                  tabName === `withdrawCollateral` ? `collateral` : `insurance`
              }
            };
            break;
          }
          case `depositCollateral`:
          case `depositInsurance`: {
            action = {
              account: token.contract,
              name: "transfer",
              data: {
                from: this.getAccountName,
                to: this.vigorContractName,
                quantity,
                memo:
                  tabName === `depositCollateral` ? `collateral` : `insurance`
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
        console.table(action);
        await this.$store.dispatch("user/transact", {
          actions: [action]
        });
        await this.getUserInfo();
      } catch (err) {
        console.error(err);
      } finally {
        this.loading = false;
      }
    }
  },
  async mounted() {
    this.loading = true;
    await this.$store.dispatch("global/getDacApi");
    await Promise.all(this.getUserInfo(), this.getAvailableDepositTokens());
    this.loading = false;
  },
  watch: {
    getAccountName: function() {
      this.getUserInfo();
    }
  }
};
</script>

<style lang="stylus" scoped>
@import '~variables'

.backing
  max-width: 100%;
</style>
