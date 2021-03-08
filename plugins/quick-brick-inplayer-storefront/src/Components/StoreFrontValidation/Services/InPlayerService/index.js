import * as R from "ramda";
import InPlayer from "@inplayer-org/inplayer.js";
import { inServiceLogger as logger } from "../LoggerService";

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

export async function isAuthenticated(in_player_client_id) {
  try {
    // InPlayer.Account.isAuthenticated() returns true even if token expired
    // To handle this case InPlayer.Account.getAccount() was used
    const getAccount = await InPlayer.Account.getAccountInfo();
    console.log({ getAccount });
    logger
      .createEvent()
      .setMessage(`InPlayer.Account.getAccount >> isAuthenticated: true`)
      .setLevel(XRayLogLevel.debug)
      .addData({
        in_player_client_id,
        is_authenticated: true,
      })
      .send();
    return true;
  } catch (error) {
    console.log({ error });

    const res = await error.response;
    console.log({ res });
    if (res?.status === 403) {
      await InPlayer.Account.refreshToken(in_player_client_id);
      logger
        .createEvent()
        .setMessage(
          `InPlayer.Account.getAccount >> status: ${res?.status}, is_authenticated: true`
        )
        .setLevel(XRayLogLevel.error)
        .addData({
          in_player_client_id,
          is_authenticated: true,
          error,
        })
        .send();
      return true;
    }

    logger
      .createEvent()
      .setMessage(
        `InPlayer.Account.getAccount >> status: ${res?.status}, is_authenticated: false`
      )
      .setLevel(XRayLogLevel.error)
      .addData({
        in_player_client_id,
        is_authenticated: false,
        error,
      })
      .send();
    return false;
  }
}

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
// const [item_id, access_fee_id] = inPlayerProductId.split("_");

export async function validateExternalPayment({
  receipt,
  userId,// Currently only avail for amazon, rest platform currently does not support this key
  item_id,
  access_fee_id,
  store,
}) {
  let event = logger.createEvent().setLevel(XRayLogLevel.debug).addData({
    receipt,
    item_id,
    access_fee_id,
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
    console.log({ platformName: platformName(store) });
    const response = await InPlayer.Payment.validateReceipt({
      platform: platformName(store),
      itemId: item_id,
      accessFeeId: access_fee_id,
      receipt: receipt,
      amazonUserId: isAmazonPlatform(store) ? userId : null,
    });

    if (isAmazonPlatform(store)) {
      event.addData({
        amazon_user_id: userId,
      });
    }

    event
      .addData({
        response: response,
      })
      .setMessage(`InPlayer validate external payment >> succeed: true`)
      .send();

    return response;
  } catch (error) {
    event
      .setMessage(`InPlayer validate external payment >> succeed: false`)
      .setLevel(XRayLogLevel.error)
      .addData({
        error,
        response: error?.response,
      })
      .send();
    throw error;
  }
}
