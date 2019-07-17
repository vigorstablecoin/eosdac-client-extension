<template>
  <!-- https://jungle.eosq.app/account/vigairburn12/tables?lowerBound=&scope=vigairburn12&tableName=payment -->
  <q-page class="q-pa-md">
    <!-- <div class="bg-bg1 round-borders q-pa-md shadow-4 text-text2">
      The VIG tokens are distributed via an AirBurn model. When you transfer EOS
      in to the contract ({{ contractname }}) the EOS will be burned and you'll
      be able to claim your proportional VIG amount at the next round. Each
      round
      <span v-if="contractSettings">{{
        contractSettings.quota_per_cycle.quantity
      }}</span>
      will be proportional divided based on the amount of EOS you and other
      people have burned.
    </div> -->

    <!-- <pre>{{ contractSettings }}</pre> -->

    <!-- <q-btn @click="getClaimablePayments" label="refresh claims" /> -->

    <div class="row gutter-sm q-mt-sm">
      <div class="col-sm-12 col-md-7 tester">
        <div
          v-if="contractSettings"
          class="round-border shadow-4 bg-bg1 q-pa-md bg-logo relative-position animate-fade"
        >
          <q-btn
            icon="refresh"
            @click="getCycles"
            flat
            :loading="loading_cycles"
            title="Reload data"
            class="absolute-top-right"
          />
          <div
            class="bg-primary q-pa-sm round-borders"
            style="display:inline-block; margin-top:-70px"
          >
            <countdown
              :time="getCurrentCycleStats.ms_left"
              :emit-events="true"
              @end="startNewCycle"
            >
              <template slot-scope="props">
                <div
                  class="q-title text-weight-light round-borders"
                  style="display:inline-block"
                >
                  <span>Round </span>
                  <span class="text-weight-bold">{{
                    getCurrentCycleStats.current_cycle_number
                  }}</span>
                  <span class="">/{{ getCurrentCycleStats.rounds_left }}</span>
                  <span> ends in </span>
                </div>
                <div
                  class="row items-center text-weight-light text-text2 q-subheading q-mt-xs"
                >
                  <q-icon name="mdi-timer" class="q-mr-xs" />
                  <span v-if="props.days">{{ props.days }} days,&nbsp;</span>
                  <span v-if="props.hours">{{ props.hours }} hours,&nbsp;</span>
                  <span v-if="props.minutes">
                    {{ props.minutes }} min,&nbsp;</span
                  >
                  <span>{{ props.seconds }} sec</span>
                </div>
              </template>
            </countdown>
          </div>
          <div class=" row gutter-xs  q-mt-sm">
            <div class="col-12-xs col-6-md on-left">
              <q-item class="no-padding ">
                <q-item-side icon="check" color="primary-light" />
                <q-item-main>
                  <q-item-tile label class="text-text2"
                    >EOS BURNED IN ONGOING ROUND:</q-item-tile
                  >
                  <q-item-tile sublabel class="text-text1"
                    >{{ getTotalPayInForCurrentCycle }} EOS</q-item-tile
                  >
                </q-item-main>
              </q-item>
              <q-item class="no-padding q-mt-sm">
                <q-item-side icon="check" color="primary-light" />
                <q-item-main>
                  <q-item-tile label class="text-text2"
                    >CURRENT * EOS PER VIG RATE:</q-item-tile
                  >
                  <q-item-tile sublabel class="text-text1"
                    >{{ getCurrentVigValue.toFixed(4) }} EOS/1 VIG</q-item-tile
                  >
                </q-item-main>
              </q-item>
            </div>
            <div class="col-12-xs col-6-md">
              <q-item class="no-padding">
                <q-item-side icon="check" color="primary-light" />
                <q-item-main>
                  <q-item-tile label class="text-text2"
                    >AVERAGE EOS PER VIG RATE:</q-item-tile
                  >
                  <q-item-tile sublabel class="text-text1"
                    >{{ getAverageVigValue.toFixed(4) }} EOS/1 VIG</q-item-tile
                  >
                </q-item-main>
              </q-item>
              <q-item class="no-padding q-mt-sm">
                <q-item-side icon="check" color="primary-light" />
                <q-item-main>
                  <q-item-tile label class="text-text2"
                    >AMOUNT OF VIG DIVIDED PER ROUND:</q-item-tile
                  >
                  <q-item-tile sublabel class="text-text1">{{
                    contractSettings.quota_per_cycle.quantity
                  }}</q-item-tile>
                </q-item-main>
              </q-item>
            </div>
            <!-- <div class="q-mt-md">
              EOS BURNED IN ONGOING ROUND:
              <span class="text-text1"
                >{{ getTotalPayInForCurrentCycle }} EOS</span
              >
            </div>
            <div class="q-mt-sm">
              CURRENT * EOS PER VIG RATE:
              <span class="text-text1"
                >{{ getCurrentVigValue.toFixed(4) }} EOS/1 VIG</span
              >
            </div>
            <div class="q-mt-sm">
              AVERAGE EOS PER VIG RATE:
              <span class="text-text1"
                >{{ getAverageVigValue.toFixed(4) }} EOS/1 VIG</span
              >
            </div>
            <div class="q-mt-sm">
              AMOUNT OF VIG DISTRIBUTED PER ROUND:
              <span class="text-text1">{{
                contractSettings.quota_per_cycle.quantity
              }}</span>
            </div> -->
          </div>
        </div>
        <div class="q-caption text-text2 q-mt-sm">
          * THE RATE SHOWN IS NOT FINAL. The actual amount of EOS burned per VIG
          received will be determined ONLY at the end of each Round.
        </div>
      </div>

      <div
        class="col-xs-12 col-md-8 tester"
        :class="{ 'order-last': $q.screen.lt.md }"
      >
        <div class="round-borders shadow-4 overflow-hidden">
          <table id="rounds_table" class="bg-logo">
            <thead>
              <tr class="q-title">
                <th class="text-weight-light">Round Number</th>
                <th class="text-weight-light">Total Burned EOS</th>
                <th class="text-weight-light">VIG Value (EOS)</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="(cycle, index) in cycles.slice(0, show_number_cycles)"
                :key="index"
                class="animate-fade"
              >
                <td># {{ cycle.number }}</td>
                <td>{{ cycle.total_payins.split(" ")[0] }}</td>
                <td>
                  {{ (cycle.total_payins.split(" ")[0] / 100).toFixed(4) }}
                </td>
              </tr>
            </tbody>
          </table>
          <q-btn
            label="more"
            @click="show_number_cycles += 5"
            class="full-width"
            color="primary"
          />
        </div>
      </div>

      <div class="col-xs-12 col-md-4 tester">
        <div
          class="bg-bg1 round-borders shadow-4 overflow-hidden q-mb-md bg-logo"
        >
          <div
            class="q-px-sm row justify-between items-center bg-primary "
            style="height:45px"
          >
            <q-icon name="mdi-fire" size="32px" class="text-text2" />
            <span class="q-title text-weight-light">Burn EOS</span>
            <help-btn
              content="You can claim your share of VIG tokens after the burn round ends."
              title="Claim VIG"
              color="text1"
              size="sm"
            />
          </div>
          <div class="q-pa-md">
            <div class="q-caption text-text2 q-mb-md">
              Burn EOS by transferring it to the contract "{{ contractname }}"
              owned by eosio.
            </div>
            <q-field :helper="getEstimatedTokenAmount">
              <q-input
                :dark="getIsDark"
                type="number"
                v-model="transferamount"
                color="primary-light"
                suffix="EOS"
              />
            </q-field>

            <div class="row justify-end q-mt-md">
              <q-btn
                @click="burnEos"
                icon="mdi-fire"
                label="burn"
                color="primary"
                size="md"
                :disabled="transferamount < getMinimumBurnAmount"
              />
            </div>
          </div>
        </div>
        <div class="round-borders bg-bg1 shadow-4 overflow-hidden">
          <div
            class="q-px-sm row justify-between items-center bg-primary "
            style="height:45px"
          >
            <q-icon name="mdi-wallet-outline" size="32px" class="text-text2" />
            <span class="q-title text-weight-light">Claim VIG</span>
            <help-btn
              content="You can claim your share of VIG tokens after the burn round ends."
              title="My Claimable VIG"
              color="text1"
              size="sm"
            />
          </div>
          <div
            v-if="!myclaimables.length"
            class="row justify-center q-pt-md text-text2"
          >
            No claims, first burn EOS
          </div>
          <q-list
            dense
            no-border
            highlight
            :dark="getIsDark"
            class="claimables"
          >
            <q-item
              v-for="(claim, i) in myclaimables"
              :key="`claim${i}`"
              class="animate-fade"
            >
              <q-item-side left>
                <q-icon
                  v-if="claim.claimable"
                  name="mdi-fire"
                  size="32px"
                  color="primary"
                />
                <q-icon v-else name="mdi-fire" color="negative" size="32px" />
              </q-item-side>
              <q-item-main>
                <q-item-tile label>Burned {{ claim.quantity }}</q-item-tile>
                <q-item-tile v-if="claim.claimable" sublabel>
                  claim ~{{
                    calcTokenShareForCycle(claim.quantity, claim.cycle_number)
                  }}
                  VIG from round {{ claim.cycle_number }}
                </q-item-tile>
                <q-item-tile v-if="!claim.claimable" sublabel>
                  round {{ claim.cycle_number }} in progress
                </q-item-tile>
              </q-item-main>
            </q-item>
          </q-list>
          <div class="row q-pa-md justify-end">
            <q-btn
              class="animate-pop"
              @click="claimPayments"
              label="claim"
              color="primary"
              v-if="myclaimables.length"
              :disabled="!getUserCanClaim"
            />
          </div>
          <!-- <pre>{{ myclaimables }}</pre> -->
          <!-- <pre>{{ cycles }}</pre> -->
        </div>
      </div>
    </div>
  </q-page>
</template>

<script>
import { mapGetters } from "vuex";
import countdown from "@chenfengyuan/vue-countdown";
import helpBtn from "components/controls/help-btn";
export default {
  name: "airburn",
  components: {
    countdown,
    helpBtn
  },
  data() {
    return {
      contractname: this.$configFile.configFile.contracts.airburn.name,
      contractSettings: false,
      cycles: [],
      show_number_cycles: 10,
      myclaimables: [],
      transferamount: "",
      NOW: new Date().getTime(),

      loading_cycles: false
    };
  },
  computed: {
    ...mapGetters({
      getDacApi: "global/getDacApi",
      getIsDark: "ui/getIsDark",
      getAccountName: "user/getAccountName"
    }),
    getMinimumBurnAmount() {
      if (!this.contractSettings) {
        return 9999999999;
      } else {
        return this.contractSettings.accepted_token.quantity.split(" ")[0];
      }
    },
    getCurrentVigValue() {
      if (!this.contractSettings) return 0;
      return (
        this.getTotalPayInForCurrentCycle /
        Number(this.contractSettings.quota_per_cycle.quantity.split(" ")[0])
      );
    },
    getAverageVigValue() {
      if (!this.cycles.length || !this.contractSettings) return 0;
      let total = 0;
      for (let i = 0; i < this.cycles.length; i++) {
        let c_in = parseFloat(this.cycles[i].total_payins.split(" ")[0]);
        total += c_in;
      }
      let average_in = parseFloat(total / this.cycles.length);
      return (
        average_in /
        this.contractSettings.quota_per_cycle.quantity.split(" ")[0]
      );
    },
    getEstimatedTokenAmount() {
      if (!this.contractSettings || !this.transferamount) {
        return "input amount to burn";
      }

      let price =
        (parseFloat(this.getTotalPayInForCurrentCycle) +
          parseFloat(this.transferamount)) /
        parseFloat(
          this.contractSettings.quota_per_cycle.quantity.split(" ")[0]
        );
      return `estimated token amount ${(this.transferamount / price).toFixed(
        4
      )} VIG`;
    },
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
    },
    getUserCanClaim() {
      return !!this.myclaimables.find(mc => mc.claimable === true);
    }
  },
  methods: {
    startNewCycle() {
      this.NOW = new Date().getTime();
      this.getClaimablePayments();
      this.getCycles();
    },
    calcTokenShareForCycle(burnedeos, cycle_number) {
      let eos = parseFloat(burnedeos.split(" ")[0]);
      let cycle = this.cycles.find(c => c.number == cycle_number);
      let batch = parseFloat(
        this.contractSettings.quota_per_cycle.quantity.split(" ")[0]
      );
      let total_payin = 0;
      if (cycle) {
        total_payin = parseFloat(cycle.total_payins.split(" ")[0]);
      }
      return ((eos / total_payin) * batch).toFixed(4);
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
      this.loading_cycles = true;
      let res = await this.getDacApi.eos
        .get_table_rows({
          json: true,
          code: this.contractname,
          scope: this.contractname,
          table: "cycle",
          //   upper_bound: 1,
          reverse: true,
          limit: -1
        })
        .catch(e => {
          console.log(e);
          this.loading_cycles = false;
          return false;
        });
      if (res) {
        this.cycles = res.rows;
        this.loading_cycles = false;
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
      if (res && res.rows.length) {
        let current_roundnum = this.getCurrentCycleStats.current_cycle_number;
        let claims = res.rows.map(c => {
          c.claimable = c.cycle_number < current_roundnum;
          return c;
        });
        claims = claims.filter(c => c.account == this.getAccountName);
        this.myclaimables = claims;
      } else {
        this.myclaimables = [];
      }
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
            quantity: this.transferamount.toFixed(4) + " EOS",
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

        this.getClaimablePayments();
        this.$store.dispatch("user/fetchBalances");
        this.transferamount = "";
      }
    }
  },
  async mounted() {
    await this.$store.dispatch("global/getDacApi");
    await this.getSettings();
    await this.getCycles();
    await this.getClaimablePayments();
  },
  watch: {
    getAccountName: function() {
      this.getClaimablePayments();
    }
  }
};
</script>

<style lang="stylus">
 @import '~variables'

.round{
  border-radius:50%;
}
#rounds_table {
  width: 100%;
  table-layout: fixed;
  border-collapse: collapse;

}
#rounds_table tr{
  background: var(--q-color-bg1);
}
#rounds_table th{
  background: var(--q-color-primary);
  height:45px;
}
#rounds_table td{
  text-align: center;
  vertical-align: middle;
  height:45px;
}

#rounds_table tr:hover {background-color: var(--q-color-dark);}
.claimables.q-list-dark.q-list-highlight > .q-item:hover, .q-list-dark .q-item-highlight:hover, .q-list-dark.q-list-link > .q-item:hover, .q-list-dark .q-item-link:hover {
      background-color: var(--q-color-dark);
}

.tester{
  transition: all 0.25s ease-in;
}
</style>
