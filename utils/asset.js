export const formatQuantity = ({ amountString, symbol }) => {
  const { precision, symbolCode } = symbol;
  let [pre, decimals] = String(amountString).split(`.`);

  if (!pre) pre = `0`;
  // pad with 0s to precision length, or cut off too much precision
  decimals = ((decimals || ``) + `0`.repeat(precision)).slice(0, precision);

  let result = `${pre}.${decimals}`;
  result = `${result} ${symbolCode}`;
  return result;
};
