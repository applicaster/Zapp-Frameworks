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
} from "./../Utils/Platform";
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
  await InPlayer.setConfig("development"); //TODO: Remove hard coded value
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
    logger
      .createEvent()
      .setMessage(
        `InPlayer.Asset.checkAccessForAsset >> inplayer_asset_id: ${assetId}`
      )
      .setLevel(XRayLogLevel.debug)
      .addData({
        inplayer_asset_id: assetId,
      })
      .send();

    const asset = await InPlayer.Asset.checkAccessForAsset(assetId);
    console.log({ asset });
    const src = getSrcFromAsset(asset);
    console.log({ src });

    const cookies = getCookiesFromAsset(asset);
    console.log({ cookies });

    logger
      .createEvent()
      .setMessage(
        `InPlayer.Asset.checkAccessForAsset Completed >> inplayer_asset_id: ${assetId} >> title: ${asset?.title} src: ${src}`
      )
      .setLevel(XRayLogLevel.debug)
      .addData({
        inplayer_asset_id: assetId,
        inplayer_asset: asset,
        src,
        cookies,
        inplayer_asset_content: getInPlayerContent(asset),
      })
      .send();

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
      event
        .setMessage(
          `InPlayer.Asset.checkAccessForAsset Failed >> status: ${error?.response?.status}, url: ${error?.response?.request?.responseURL} >> retry to load`
        )
        .setLevel(XRayLogLevel.debug)
        .addData({
          inplayer_asset_id: assetId,
          interval: newInterval,
          tries: newTries,
        })
        .send();

      return await checkAccessForAsset({
        assetId,
        retryInCaseFail: true,
        interval: newInterval,
        tries: newTries,
      });
    } else {
      const isPurchaseRequired = assetPaymentRequired(error);

      if (isPurchaseRequired) {
        event
          .addData({
            is_purchase_required: isPurchaseRequired,
          })
          .setMessage(
            `InPlayer.Asset.checkAccessForAsset >> status: ${error?.response?.status}, url: ${error?.response?.request?.responseURL}, is_purchase_required: ${isPurchaseRequired}`
          )
          .setLevel(XRayLogLevel.debug)
          .send();

        throw { ...error, requestedToPurchase: isPurchaseRequired };
      }
      event
        .setMessage(
          `InPlayer.Asset.checkAccessForAsset Failed >> status: ${error?.response?.status}, url: ${error?.response?.request?.responseURL}`
        )
        .setLevel(XRayLogLevel.error)
        .send();
      throw error;
    }
  }
}

export async function getAccessFees(assetId) {
  try {
    logger
      .createEvent()
      .setMessage(
        `InPlayer.Asset.getAssetAccessFees >> inplayer_asset_id: ${assetId}`
      )
      .setLevel(XRayLogLevel.debug)
      .addData({
        inplayer_asset_id: assetId,
      })
      .send();

    const retVal = await InPlayer.Asset.getAssetAccessFees(assetId);
    const data = retVal?.data;
    console.log({ acessFeesResult: data });
    const descriptions = R.map(R.prop("description"))(data);
    logger
      .createEvent()
      .setMessage(
        `InPlayer.Asset.getAssetAccessFees Completed >> inplayer_asset_id: ${assetId} >> fees_count: ${data.length}, fee_descriptions: ${descriptions}`
      )
      .setLevel(XRayLogLevel.debug)
      .addData({
        inplayer_asset_access_fees: data,
        inplayer_asset_id: assetId,
      })
      .send();
    return data;
  } catch (error) {
    logger
      .createEvent()
      .setMessage(
        `InPlayer.Asset.getAssetAccessFees Failed >> status: ${error?.response?.status}, url: ${error?.response?.request?.responseURL}, inplayer_asset_id: ${assetId}`
      )
      .setLevel(XRayLogLevel.error)
      .addData({
        inplayer_asset_id: assetId,
        error,
      })
      .send();
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
    console.log({ error });
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
    console.log({ error });
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

//TODO: This func not working with Web, implement proper way in future
export async function validateExternalPayment({
  receipt,
  userId,
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
