import * as R from "ramda";
import InPlayer from "@inplayer-org/inplayer.js";
import {
  createLogger,
  BaseSubsystem,
  BaseCategories,
} from "../../../../Services/LoggerService";
import { assetPaymentRequired } from "../../../../Utils/PayloadUtils";

export const logger = createLogger({
  subsystem: `${BaseSubsystem}/${BaseCategories.INPLAYER_SERVICE}`,
  category: BaseCategories.INPLAYER_SERVICE,
});

export async function checkAccessForAsset({ assetId }) {
  try {
    logger.debug({
      message: `InPlayer.Asset.checkAccessForAsset >> inplayer_asset_id: ${assetId}`,
      data: {
        inplayer_asset_id: assetId,
      },
    });

    const axoisAsset = await InPlayer.Asset.checkAccessForAsset(assetId);
    const asset = axoisAsset?.data;
    const src = getSrcFromAsset(asset);

    const cookies = getCookiesFromAsset(asset);

    logger.debug({
      message: `InPlayer.Asset.checkAccessForAsset Completed >> inplayer_asset_id: ${assetId} >> title: ${asset?.title} src: ${src}`,
      data: {
        inplayer_asset_id: assetId,
        inplayer_asset: asset,
        src,
        cookies,
        inplayer_asset_content: getInPlayerContent(asset),
      },
    });

    return { asset, src, cookies };
  } catch (error) {
    console.log({ error });

    const isPurchaseRequired = assetPaymentRequired(error);

    if (isPurchaseRequired) {
      logger.debug({
        message: `InPlayer.Asset.checkAccessForAsset >> status: ${error?.response?.status}, url: ${error?.response?.request?.responseURL}, is_purchase_required: ${isPurchaseRequired}`,
        data: {
          is_purchase_required: isPurchaseRequired,

          response: error?.response,
          is_purchase_required: false,
          error,
        },
      });

      throw { ...error, requestedToPurchase: isPurchaseRequired };
    }
    logger.error({
      message: `InPlayer.Asset.checkAccessForAsset Failed >> status: ${error?.response?.status}, url: ${error?.response?.request?.responseURL}`,
      data: {
        response: error?.response,
        is_purchase_required: false,
        error,
      },
    });
    throw error;
  }
}

export async function getAccessFees(assetId) {
  try {
    logger.debug({
      message: `InPlayer.Asset.getAssetAccessFees >> inplayer_asset_id: ${assetId}`,
      data: {
        inplayer_asset_id: assetId,
      },
    });

    const retVal = await InPlayer.Asset.getAssetAccessFees(assetId);
    const data = retVal?.data;
    console.log({ acessFeesResult: data });
    const descriptions = R.map(R.prop("description"))(data);
    logger.debug({
      message: `InPlayer.Asset.getAssetAccessFees Completed >> inplayer_asset_id: ${assetId} >> fees_count: ${data.length}, fee_descriptions: ${descriptions}`,
      data: {
        inplayer_asset_access_fees: data,
        inplayer_asset_id: assetId,
      },
    });
    return data;
  } catch (error) {
    logger.error({
      message: `InPlayer.Asset.getAssetAccessFees Failed >> status: ${error?.response?.status}, url: ${error?.response?.request?.responseURL}, inplayer_asset_id: ${assetId}`,
      data: {
        inplayer_asset_id: assetId,
        error,
      },
    });

    throw error;
  }
}
