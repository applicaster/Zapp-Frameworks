import * as R from "ramda";
import InPlayer from "@inplayer-org/inplayer.js";
import { inServiceLogger as logger } from "../LoggerService";

export async function checkAccessForAsset({
  assetId,
  retryInCaseFail = false,
  interval = 1000,
  tries = 5,
}) {
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
    const event = logger.createEvent().addData({
      response: error?.response,
      is_purchase_required: false,
      error,
    });

    if (retryInCaseFail && tries > 0) {
      await new Promise((r) => setTimeout(r, interval));
      const newInterval = interval * 2;
      const newTries = tries - 1;

      logger.debug({
        message: `InPlayer.Asset.checkAccessForAsset Failed >> status: ${error?.response?.status}, url: ${error?.response?.request?.responseURL} >> retry to load`,
        data: {
          inplayer_asset_id: assetId,
          interval: newInterval,
          tries: newTries,
          response: error?.response,
          is_purchase_required: false,
          error,
        },
      });

      return await checkAccessForAsset({
        assetId,
        retryInCaseFail: true,
        interval: newInterval,
        tries: newTries,
      });
    } else {
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
}

export async function isAuthenticated(in_player_client_id) {
  try {
    // InPlayer.Account.isAuthenticated() returns true even if token expired
    // To handle this case InPlayer.Account.getAccount() was used
    await InPlayer.Account.getAccountInfo();

    logger.debug({
      message: `InPlayer.Account.getAccount >> isAuthenticated: true`,
      data: {
        in_player_client_id,
        is_authenticated: true,
      },
    });
    return true;
  } catch (error) {
    const res = await error.response;
    console.log({ res });
    if (res?.status === 403) {
      await InPlayer.Account.refreshToken(in_player_client_id);

      logger.warning({
        message: `InPlayer.Account.getAccount >> status: ${res?.status}, is_authenticated: true`,
        data: {
          in_player_client_id,
          is_authenticated: true,
          error,
        },
      });
      return true;
    }

    logger.warning({
      message: `InPlayer.Account.getAccount >> status: ${res?.status}, is_authenticated: false`,
      data: {
        in_player_client_id,
        is_authenticated: false,
        error,
      },
    });

    return false;
  }
}

function isAmazonPlatform(store) {
  return store && store === "amazon";
}
export const isApplePlatform = Platform.OS === "ios";
export const isAndroidPlatform = Platform.OS === "android";

function platformName(store) {
  if (isAmazonPlatform(store)) {
    return "amazon";
  } else if (isAndroidPlatform) {
    return "google-play";
  } else if (isApplePlatform) {
    return "apple";
  } else {
    throw new Error("Platform can not be received");
  }
}

export async function validateExternalPayment({
  receipt,
  amazon_user_id,
  item_id,
  access_fee_id,
  store,
}) {
  console.log("validateExternalPayment", {
    receipt,
    amazon_user_id,
    item_id,
    access_fee_id,
    store,
  });

  try {
    if (!receipt) {
      throw new Error("Payment receipt is a required parameter!");
    }
    if (!item_id) {
      throw new Error("Payment item_id is a required parameter!");
    }
    if (!access_fee_id) {
      throw new Error("Payment access_fee_id is a required parameter!");
    }
    const response = await InPlayer.Payment.validateReceipt({
      platform: platformName(store),
      itemId: item_id,
      accessFeeId: access_fee_id,
      receipt: receipt,
      amazonUserId: isAmazonPlatform(store) ? amazon_user_id : null,
    });

    logger.debug({
      message: `InPlayer validate external payment >> succeed: true`,
      data: {
        receipt,
        item_id,
        access_fee_id,
        amazon_user_id,
        response: response,
      },
    });

    return response;
  } catch (error) {
    logger.error({
      message: `InPlayer validate external payment >> succeed: false`,
      data: {
        receipt,
        item_id,
        access_fee_id,
        amazon_user_id,
        error,
        response: error?.response,
      },
    });
    throw error;
  }
}
