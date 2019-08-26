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
  const api = await dispatch("global/getDacApi", false, { root: true });
  const vigorContractName = this._vm.$configFile.configFile.contracts.vigor
    .name;

  const coinstatResult = await api.eos.get_table_rows({
    json: true,
    code: vigorContractName,
    scope: vigorContractName,
    table: "coinstat",
    index_position: 1,
    lower_bound: 0
  });

  const availableTokens = coinstatResult.rows
    .map(row => {
      // reconstruct token from supply. assume issuer is also where the token is deployed
      const [amount, symbolCode] = row.supply.split(` `);
      const precision = amount.length - 1 - amount.indexOf(`.`);

      return {
        contract: row.issuer,
        symbol: {
          symbolCode,
          precision
        }
      };
    })
    // make vigor token not available for backing
    .filter(({ symbol: { symbolCode } }) => symbolCode !== `VIGOR`);

  commit("setAvailableTokens", availableTokens);
  return availableTokens;
}
