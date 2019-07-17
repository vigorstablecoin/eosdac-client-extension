<template>
  <div>
    <line-chart
      ref="linechart"
      :chartData="chartData"
      :options="chartOptions"
      :width="width"
      :height="height"
    />
  </div>
</template>

<script>
import { colors } from "quasar";
import lineChart from "components/ui/line-chart";
import { mapGetters } from "vuex";

export default {
  name: "priceChart",
  components: {
    lineChart
  },
  props: {
    data: {},
    legend: {
      type: Boolean,
      default: false
    },

    responsive: {
      type: Boolean,
      default: true
    },
    width: {
      type: Number,
      default: 300
    },
    height: {
      type: Number,
      default: 300
    }
  },
  data() {
    return {
      chartData: null,
      chartOptions: {
        responsive: this.responsive,
        maintainAspectRatio: false,
        legend: {
          display: this.legend
        },
        scales: {
          xAxes: [
            {
              gridLines: {
                color: "rgba(0, 0, 0, 0)"
              },
              ticks: {
                fontColor: colors.getBrand("text2"),
                beginAtZero: false,
                stepSize: 15
              }
            }
          ],
          yAxes: [
            {
              gridLines: {
                color: "rgba(0, 0, 0, 0)",
                zeroLineColor: "#3E3E3E"
              },
              ticks: {
                callback: function(value) {
                  return Number(value).toFixed(3);
                },
                // stepSize: 0.002,
                display: true,
                beginAtZero: true,
                fontColor: colors.getBrand("text2")
              }
            }
          ]
        }
      }
    };
  },
  computed: {
    ...mapGetters({})
  },
  methods: {
    getGradient() {
      if (!this.$refs.linechart || !this.$refs.linechart.$refs) {
        return;
      }
      let { r, g, b } = colors.hexToRgb(colors.getBrand("primary"));
      // console.log(r,g,b)
      let gradient = this.$refs.linechart.$refs.canvas
        .getContext("2d")
        .createLinearGradient(0, 0, 0, 450);
      gradient.addColorStop(0, `rgba(${r}, ${g}, ${b}, 0.5)`);
      gradient.addColorStop(0.5, `rgba(${r}, ${g}, ${b}, 0.25)`);
      gradient.addColorStop(1, `rgba(${r}, ${g}, ${b}, 0)`);
      return gradient;
    },
    async setData() {
      let reverse = JSON.parse(JSON.stringify(this.data)).reverse();
      this.chartData = {
        labels: reverse.map(d => d.number),
        datasets: [
          {
            label: `Price in EOS`,
            data: reverse.map(d => d.vig_value),
            lineTension: 0,
            backgroundColor: this.getGradient(),
            borderColor: colors.getBrand("primary"),
            pointBackgroundColor: "none",
            borderWidth: 1,
            pointBorderColor: "none",
            pointRadius: 0
          }
        ]
      };
    }
  },
  async mounted() {
    this.setData();
  },
  watch: {
    data: function() {
      this.setData();
    }
  }
  //
};
</script>
