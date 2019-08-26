import createPersistedState from "vuex-persistedstate";
import example from "./example";
import vigor from "./vigor";

const store_extension = {
  modules: {
    example,
    vigor
  },
  plugins: [
    createPersistedState({
      key: "example",
      paths: ["example.example"]
    })
  ]
};

export default store_extension;
