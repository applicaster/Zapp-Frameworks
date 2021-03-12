import { getInPlayerContent, getInPlayerAssetType } from "../InPlayerResponse";
import { getSrcForJWPlayer } from "./JWPlayerAsset";
import { getSrcForHTML } from "./HTMLAsset";

const SUPPORTED_ASSET_TYPES = {
  JW_ASSET: "jw_asset",
  HTML: "html_asset",
};

export const getCookiesFromAsset = (inPlayerItemAccess) => {
  const { cookies = null } =
    inPlayerItemAccess && getInPlayerContent(inPlayerItemAccess);
  return cookies;
};

export const getSrcFromAsset = (inPlayerItemAccess) => {
  console.log("getSrcFromAsset");

  const inPlayerContent =
    inPlayerItemAccess && getInPlayerContent(inPlayerItemAccess);
  console.log({ inPlayerContent });
  if (inPlayerContent) {
    const src = retrieveSrcFromDefault({ inPlayerContent });
    console.log({ src });

    if (src) {
      return src;
    } else {
      const fallbackSrc = tryFallBackLogicFromMapping({
        inPlayerContent,
        inPlayerItemAccess,
      });
      return fallbackSrc;
    }
  }
  return null;
};

const retrieveSrcFromDefault = ({ inPlayerContent }) => {
  const { mobile_url = null } = inPlayerContent;
  return mobile_url && mobile_url.length > 0 ? mobile_url : null;
};

const tryFallBackLogicFromMapping = ({
  inPlayerContent,
  inPlayerItemAccess,
}) => {
  const inPlayerAssetType = getInPlayerAssetType(inPlayerItemAccess);
  if (inPlayerAssetType) {
    switch (inPlayerAssetType) {
      case SUPPORTED_ASSET_TYPES.JW_ASSET:
        return getSrcForJWPlayer({ inPlayerItemAccess, inPlayerContent });
      case SUPPORTED_ASSET_TYPES.HTML:
        return getSrcForHTML({ inPlayerItemAccess, inPlayerContent });
      default:
        break;
    }
  }
  return null;
};
