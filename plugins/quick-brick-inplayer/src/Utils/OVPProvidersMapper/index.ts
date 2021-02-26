import { getInPlayerContent, getInPlayerAssetType } from "../InPlayerResponse";
import { getSrcForJWPlayer } from "./JWPlayerAsset";
import { getSrcForHTML } from "./HTMLAsset";
import { GetItemAccessV1 } from "@inplayer-org/inplayer.js";

const SUPPORTED_ASSET_TYPES = {
  JW_ASSET: "jw_asset",
  HTML: "html_asset",
};

export function getCookiesFromAsset(inPlayerItemAccess: GetItemAccessV1) {
  const { cookies = null } =
    inPlayerItemAccess && getInPlayerContent(inPlayerItemAccess);
  return cookies;
}

export function getSrcFromAsset(inPlayerItemAccess: GetItemAccessV1): string {
  const inPlayerContent =
    inPlayerItemAccess && getInPlayerContent(inPlayerItemAccess);
  console.log({ inPlayerContent });
  if (inPlayerContent) {
    const src = retrieveSrcFromDefault(inPlayerContent);
    console.log({ src });

    if (src) {
      return src;
    } else {
      const fallbackSrc = tryFallBackLogicFromMapping(
        inPlayerContent,
        inPlayerItemAccess
      );
      return fallbackSrc;
    }
  }
  return null;
}

function retrieveSrcFromDefault(inPlayerContent) {
  const { mobile_url = null } = inPlayerContent;
  return mobile_url && mobile_url.length > 0 ? mobile_url : null;
}

function tryFallBackLogicFromMapping(
  inPlayerContent,
  inPlayerItemAccess: GetItemAccessV1
) {
  const inPlayerAssetType = getInPlayerAssetType(inPlayerItemAccess);
  if (inPlayerAssetType) {
    switch (inPlayerAssetType) {
      case SUPPORTED_ASSET_TYPES.JW_ASSET:
        return getSrcForJWPlayer(inPlayerContent);
      case SUPPORTED_ASSET_TYPES.HTML:
        return getSrcForHTML(inPlayerItemAccess, inPlayerContent);
      default:
        break;
    }
  }
  return null;
}
