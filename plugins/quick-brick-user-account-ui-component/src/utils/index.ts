import * as R from "ramda";

/**
 * Accepts any value and determines if we need to return string, null, number, or identity
 * This addresses the issues that arrise with using Number() to sanitize values
 * with Number(false) => 0, Number(null) => 0 which was causing problems
 * @param {*} value any type of value
 * @returns {*} string, null, number, or identity
 */
export const handleStyleType = R.cond([
  [R.isNil, R.identity],
  [R.isEmpty, R.identity],
  [R.is(Boolean), R.identity],
  [R.is(Number), R.identity],
  [R.is(String), (val) => (isNaN(Number(val)) ? val : Number(val))],
  [R.T, R.identity],
]);

/**
 * Gets a style key from the style object and returns a value that can be used in styles
 * @param {String} key i.e. button_icon_width
 * @param {Object} stylesObj styles object with keys from zapp { button_icon_width: "10" }
 * @returns {*} handleStyleType(value), returns any type that can be used as styles
 */
export function getValue(key, stylesObj) {
  const value = R.propOr(null, key, stylesObj);

  return handleStyleType(value);
}
