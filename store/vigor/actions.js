export async function fetchUserInfo(
  { state, rootState, commit, dispatch },
  accountname = false
) {
  const accountN = accountname || rootState.user.accountName;
  if (!accountN) return null;

  const api = await dispatch("global/getDacApi", false, { root: true });
  const vigorContractName = this._vm.$configFile.configFile.contracts.vigor
    .name;

  const userInfoResult = await api.eos.get_table_rows({
    json: true,
    code: vigorContractName,
    scope: vigorContractName,
    table: "user",
    key_type: `name`,
    index_position: 1,
    lower_bound: `${accountN}`,
    upper_bound: `${accountN}`,
    limit: 1
  });
  const userInfo = userInfoResult.rows[0];

  if (!accountname) {
    commit("setUserInfo", userInfo);
    return userInfo;
  } else {
    return userInfo;
  }
}

export async function fetchAvailableTokens({
  state,
  rootState,
  commit,
  dispatch
}) {
  // TODO: fetch these extended assets from a list somewhere
  // right now hard-coded in vigor's apply function
  // https://github.com/vigorstablecoin/vigor/blob/dfe964029831ed9ece2f5e929ddbb1a6a1332c53/contracts/vigor/src/vigor.cpp#L896
  const availableTokens = [
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

  commit("setAvailableTokens", availableTokens);
  return availableTokens;
}
