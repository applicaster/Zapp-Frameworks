import * as R from "ramda";

/**
 *
 * @param {String} label current label
 * @param {Array.<{label: String, value: any}>} labels list of labels with current values
 *
 *
 */
export const findNextEmptyLabel = (label, labels) => {
  const currentLabelIndex = R.findIndex(R.propEq("label", label), labels);
  if (currentLabelIndex === -1) {
    throw new Error(
      `Provided label "${label}" doesn't exist in the provided labels list`,
      labels
    );
  }
  const nextLabels = R.compose(
    R.drop(1),
    R.flatten,
    R.reverse,
    R.splitAt(currentLabelIndex)
  )(labels);

  const nextEmpty = R.find(R.propEq("value", ""))(nextLabels);

  return R.propOr(null, "label")(nextEmpty);
};
