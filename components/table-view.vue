<template>
  <q-list no-border highlight multiline :dark="getIsDark" class="list">
    <q-item v-for="(value, key) in json" :key="key" class="q-py-sm">
      <q-item-side color="primary-light" top>
        <div class="itemKey uppercase text-weight-medium">{{ key }}</div>
      </q-item-side>
      <q-item-main>
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
        <span v-else>{{ formatValue(value) }}</span>
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
    formatValue(val) {
      // if string or number is a float, round decimals only if necessary
      if (!isNaN(val) && val.toString().indexOf(".") !== -1)
        return +(+val).toFixed(6);

      return val;
    }
  }
};
</script>

<style lang="stylus" scoped>
@import '~variables'

.list
  max-height: 520px;
  overflow-y: auto;
  overscroll-behavior: contain;
  /* For firefox: https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Scrollbars */
  scrollbar-color: var(--q-color-dark) var(--q-color-bg2);
  scrollbar-width: thin;

  &::-webkit-scrollbar
    width: 10px;

  &::-webkit-scrollbar-track
    background: var(--q-color-bg2);

  &::-webkit-scrollbar-thumb
    background: var(--q-color-dark);

.itemKey
  width: 120px;
</style>
