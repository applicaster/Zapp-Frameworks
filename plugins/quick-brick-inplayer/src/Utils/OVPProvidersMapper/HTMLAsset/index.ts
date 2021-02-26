import { GetItemAccessV1 } from "@inplayer-org/inplayer.js";
import { func } from "prop-types";
import { findInPlayerMetadata } from "../../InPlayerResponse";

export function getSrcForHTML(
  inPlayerItemAccess: AxiosResponse<GetItemAccessV1>,
  inPlayerContent
) {
  const applicasterAssetType = findInPlayerMetadata(
    inPlayerItemAccess,
    "asset_type"
  );
  return inPlayerContent && applicasterAssetType === "video"
    ? inPlayerContent
    : null;
}
