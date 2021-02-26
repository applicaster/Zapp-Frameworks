import * as R from "ramda";
import { parseJsonIfNeeded } from "@applicaster/zapp-react-native-utils/functionUtils";
import { GetItemAccessV1 } from "@inplayer-org/inplayer.js";

export function getInPlayerContent(
  inPlayerItemAccess: AxiosResponse<GetItemAccessV1>
) {
  return R.compose(
    parseJsonIfNeeded,
    R.trim,
    R.path(["data", "item", "content"])
  )(inPlayerItemAccess);
}

export function getInPlayerAssetType(
  inPlayerItemAccess: AxiosResponse<GetItemAccessV1>
) {
  return R.path(["data", "item", "item_type", "name"])(inPlayerItemAccess);
}

export function findInPlayerMetadata(
  inPlayerItemAccess: AxiosResponse<GetItemAccessV1>,
  value: string
): string {
  const nonEmptyString = (str) => typeof str === "string" && !!str;
  return R.compose(
    R.unless(nonEmptyString, R.always(null)),
    R.prop("value"),
    R.ifElse(Array.isArray, R.find(R.propEq("name", value)), R.always(null)),
    R.path(["data", "item", "metadata"])
  )(inPlayerItemAccess);
}
