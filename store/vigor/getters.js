export function getUserInfo(state) {
  return state.userInfo;
}

export function getAvailableTokens(state) {
  return state.availableTokens;
}

export const getVigorToken = () => vigorConfigObj => {
  return {
    contract: vigorConfigObj.name,
    symbol: {
      symbolCode: `VIGOR`,
      precision: 4
    }
  };
};
