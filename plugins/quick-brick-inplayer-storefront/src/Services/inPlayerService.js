import * as R from "ramda";
import InPlayer from "@inplayer-org/inplayer.js";

import {
  localStorageGet,
  localStorageSet,
} from "../Services/LocalStorageService";
import {
  getSrcFromAsset,
  getCookiesFromAsset,
} from "../Utils/OVPProvidersMapper";
import { assetPaymentRequired, externalAssetData } from "../Utils/PayloadUtils";
import {
  isAmazonPlatform,
  isApplePlatform,
  isAndroidPlatform,
} from "../Utils/Platform";
import { getInPlayerContent } from "../Utils/InPlayerResponse";
import {
  createLogger,
  BaseSubsystem,
  BaseCategories,
  XRayLogLevel,
} from "../Services/LoggerService";

export const logger = createLogger({
  subsystem: `${BaseSubsystem}/${BaseCategories.INPLAYER_SERVICE}`,
  category: BaseCategories.INPLAYER_SERVICE,
});

const IN_PLAYER_LAST_EMAIL_USED_KEY = "com.inplayer.lastEmailUsed";

export async function setConfig(environment = "production") {
  logger
    .createEvent()
    .setLevel(XRayLogLevel.debug)
    .addData({
      environment: environment,
    })
    .setMessage(`Set InPlayer environment: ${environment}`)
    .send();
  await InPlayer.setConfig(environment);
}

export async function getPurchaseHistory() {
  try {
    const result = await InPlayer.Payment.getPurchaseHistory("active", 0, 10);
    return result?.data?.collection;
  } catch (error) {
    throw error;
  }
}

export async function getAssetByExternalId(payload) {
  const assetData = externalAssetData({ payload });
  const errorEvent = logger
    .createEvent()
    .setMessage(
      `InPlayer.Asset.getExternalAsset >> Can not retrieve external_asset_id`
    )
    .setLevel(XRayLogLevel.error);

  if (assetData) {
    const { externalAssetId, inplayerAssetType } = assetData;
    try {
      logger
        .createEvent()
        .setMessage(
          `InPlayer.Asset.getExternalAsset >> external_asset_id: ${externalAssetId}, inplayer_asset_type: ${inplayerAssetType}`
        )
        .setLevel(XRayLogLevel.debug)
        .addData({
          external_asset_data: {
            external_asset_id: externalAssetId,
            inplayer_asset_type: inplayerAssetType,
          },
        })
        .send();

      const result = await InPlayer.Asset.getExternalAsset(
        inplayerAssetType,
        externalAssetId
      );

      const retVal = result?.data?.id;
      if (retVal) {
        logger
          .createEvent()
          .setMessage(
            `InPlayer.Asset.getExternalAsset Completed >> external_asset_id: ${externalAssetId}, inplayer_asset_type: ${inplayerAssetType} >> Result: inplayer_asset_id: ${retVal}, title: ${result?.title}`
          )
          .setLevel(XRayLogLevel.debug)
          .addData({
            inplayer_asset_id: retVal,
            external_asset: result,
            external_asset_data: {
              external_asset_id: externalAssetId,
              inplayer_asset_type: inplayerAssetType,
            },
            exernal_response: result,
          })
          .send();
        return retVal;
      } else {
        errorEvent
          .addData({
            external_asset_data: {
              external_asset_id: externalAssetId,
              inplayer_asset_type: inplayerAssetType,
            },
            exernal_response: result,
          })
          .send();
        return null;
      }
    } catch (error) {
      errorEvent
        .addData({
          external_asset_data: {
            external_asset_id: externalAssetId,
            inplayer_asset_type: inplayerAssetType,
          },
          error,
        })
        .setMessage(
          `InPlayer.Asset.getExternalAsset >> error message ${error.message}`
        )
        .send();
    }
  } else {
    errorEvent.send();
    return null;
  }
}

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

export async function login({ email, password, clientId, referrer }) {
  email && (await localStorageSet(IN_PLAYER_LAST_EMAIL_USED_KEY, email));
  try {
    const retVal = await InPlayer.Account.signIn({
      email,
      password,
      clientId,
      referrer,
    });
    logger
      .createEvent()
      .setMessage(
        `InPlayer.Account.signIn >> succeed: true, email: ${email}, password: ${password}, in_player_client_id: ${clientId}, referrer: ${referrer}`
      )
      .setLevel(XRayLogLevel.debug)
      .addData({
        email,
        password,
        in_player_client_id: clientId,
        referrer,
        succeed: true,
      })
      .send();
    return retVal;
  } catch (error) {
    const { response } = error;

    logger
      .createEvent()
      .setMessage(
        `InPlayer.Account.signIn >> status: ${response?.status}, url: ${response?.request?.responseURL}, isAuthenticated: true, email: ${email}, password: ${password}, in_player_client_id: ${clientId}, referrer: ${referrer} `
      )
      .setLevel(XRayLogLevel.error)
      .addData({
        email,
        password,
        in_player_client_id: clientId,
        referrer,
        is_authenticated: false,
        error,
      })
      .send();
    throw error;
  }
}

export async function signUp(params) {
  const { fullName, email, password, clientId, referrer, brandingId } = params;

  try {
    const retVal = await InPlayer.Account.signUp({
      fullName,
      email,
      password,
      passwordConfirmation: password,
      clientId,
      referrer,
      metadata: {},
      type: "consumer",
      brandingId,
    });
    logger
      .createEvent()
      .setMessage(
        `InPlayer.Account.signUp >> succeed: true, fullName:${fullName}, email: ${email}, password: ${password}, password_confirmation: ${password}, in_player_client_id:${clientId}, referrer: ${referrer}`
      )
      .setLevel(XRayLogLevel.debug)
      .addData({
        fullName,
        email,
        password,
        password_confirmation: password,
        in_player_client_id: clientId,
        referrer,
        metadata: {},
        type: "consumer",
        succeed: true,
      })
      .send();
    return retVal;
  } catch (error) {
    logger
      .createEvent()
      .setMessage(
        `InPlayer.Account.signIn >> status: ${error?.response?.status}, url: ${error?.response?.request?.responseURL}, succeed: false, fullName: ${fullName}, email: ${email}, password: ${password}, password_confirmation: ${password}, in_player_client_id: ${clientId}, referrer: ${referrer}`
      )
      .setLevel(XRayLogLevel.error)
      .addData({
        fullName,
        email,
        password,
        password_confirmation: password,
        in_player_client_id: clientId,
        referrer,
        metadata: {},
        type: "consumer",
        succeed: false,
        error,
      })
      .send();
    throw error;
  }
}

export async function requestPassword({ email, clientId, brandingId }) {
  try {
    const retVal = await InPlayer.Account.requestNewPassword({
      email,
      merchantUuid: clientId,
      brandingId,
    });
    logger
      .createEvent()
      .setMessage(
        `InPlayer.Account.requestNewPassword >> succeed: true, email: ${email}, in_player_client_id: ${clientId}`
      )
      .setLevel(XRayLogLevel.debug)
      .addData({ email, in_player_client_id: clientId, succeed: true })
      .send();
    return retVal;
  } catch (error) {
    logger
      .createEvent()
      .setMessage(
        `InPlayer.Account.requestNewPassword >> status: ${error?.response?.status}, url: ${error?.response?.request?.responseURL}, succeed: false, email: ${email}, in_player_client_id: ${clientId}`
      )
      .setLevel(XRayLogLevel.error)
      .addData({
        email,
        in_player_client_id: clientId,
        metadata: ["Dummy"],
        type: "consumer",
        succeed: false,
        error,
      })
      .send();
    throw error;
  }
}

export async function setNewPassword({ password, token, brandingId }) {
  try {
    await InPlayer.Account.setNewPassword(
      {
        password,
        passwordConfirmation: password,
        brandingId,
      },
      token
    );
    logger
      .createEvent()
      .setMessage(
        `InPlayer.Account.setNewPassword >> succeed: true, password: ${password}, password_confirmation: ${password}`
      )
      .setLevel(XRayLogLevel.debug)
      .addData({ password, password_confirmation: password, succeed: true })
      .send();
  } catch (error) {
    logger
      .createEvent()
      .setMessage(
        `InPlayer.Account.setNewPassword >> status: ${error?.response?.status}, url: ${error?.response?.request?.responseURL}, succeed: false, password: ${password}, password_confirmation: ${password}`
      )
      .setLevel(XRayLogLevel.error)
      .addData({
        password,
        password_confirmation: password,
        succeed: false,
        error,
      })
      .send();
    throw error;
  }
}

export async function signOut() {
  try {
    const retVal = await InPlayer.Account.signOut();
    logger
      .createEvent()
      .setMessage(`InPlayer.Account.signOut >> succeed: true`)
      .setLevel(XRayLogLevel.debug)
      .addData({ succeed: true })
      .send();
    return retVal;
  } catch (error) {
    logger
      .createEvent()
      .setMessage(`InPlayer.Account.signOut >> succeed: false`)
      .setLevel(XRayLogLevel.error)
      .addData({
        succeed: false,
        error,
      })
      .send();
    throw error;
  }
}

export async function getLastEmailUsed() {
  return localStorageGet(IN_PLAYER_LAST_EMAIL_USED_KEY);
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

export async function validateExternalPayment({
  receipt,
  amazon_user_id,
  item_id,
  access_fee_id,
  store,
}) {
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
