import * as R from "ramda";
import { parseJsonIfNeeded } from "@applicaster/zapp-react-native-utils/functionUtils";

export const getInPlayerContent = (inPlayerItemAccess) => {
  return R.compose(
    parseJsonIfNeeded,
    R.trim,
    R.path(["data", "item", "content"])
  )(inPlayerItemAccess);
};

export const getInPlayerAssetType = (inPlayerItemAccess) => {
  return R.path(["data", "item", "item_type", "name"])(inPlayerItemAccess);
};

export const findInPlayerMetadata = ({ inPlayerItemAccess, value }) => {
  const nonEmptyString = (str) => typeof str === "string" && !!str;
  return R.compose(
    R.unless(nonEmptyString, R.always(null)),
    R.prop("value"),
    R.ifElse(Array.isArray, R.find(R.propEq("name", value)), R.always(null)),
    R.path(["data", "item", "metadata"])
  )(inPlayerItemAccess);
};
