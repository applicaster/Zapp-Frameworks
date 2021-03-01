import InPlayer from "@inplayer-org/inplayer.js";

import {
  localStorageGet,
  localStorageSet,
} from "../Services/LocalStorageService";

import { externalAssetData } from "../Utils/PayloadUtils";
import {
  isAmazonPlatform,
  isApplePlatform,
  isAndroidPlatform,
} from "./../Utils/Platform";
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
  logger.debug({
    message: `Set InPlayer environment: ${environment}`,
    data: { environment: environment },
  });
  await InPlayer.setConfig("development");
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
      logger.debug({
        message: `InPlayer.Asset.getExternalAsset >> external_asset_id: ${externalAssetId}, inplayer_asset_type: ${inplayerAssetType}`,
        data: {
          external_asset_data: {
            external_asset_id: externalAssetId,
            inplayer_asset_type: inplayerAssetType,
          },
        },
      });

      const result = await InPlayer.Asset.getExternalAsset(
        inplayerAssetType,
        externalAssetId
      );

      const retVal = result?.data?.id;
      if (retVal) {
        logger.debug({
          message: `InPlayer.Asset.getExternalAsset Completed >> external_asset_id: ${externalAssetId}, inplayer_asset_type: ${inplayerAssetType} >> Result: inplayer_asset_id: ${retVal}, title: ${result?.title}`,
          data: {
            inplayer_asset_id: retVal,
            external_asset: result,
            external_asset_data: {
              external_asset_id: externalAssetId,
              inplayer_asset_type: inplayerAssetType,
            },
            exernal_response: result,
          },
        });
        return retVal;
      } else {
        logger.error({
          message: `InPlayer.Asset.getExternalAsset >> Can not retrieve external_asset_id`,
          data: {
            external_asset_data: {
              external_asset_id: externalAssetId,
              inplayer_asset_type: inplayerAssetType,
            },
            exernal_response: result,
          },
        });
        return null;
      }
    } catch (error) {
      logger.error({
        message: `InPlayer.Asset.getExternalAsset >> error message ${error.message}`,
        data: {
          external_asset_data: {
            external_asset_id: externalAssetId,
            inplayer_asset_type: inplayerAssetType,
          },
          exernal_response: result,
          error,
        },
      });
    }
  } else {
    logger.error({
      message: `InPlayer.Asset.getExternalAsset >> Can not retrieve external_asset_id`,
    });

    return null;
  }
}

export async function isAuthenticated(in_player_client_id) {
  try {
    // InPlayer.Account.isAuthenticated() returns true even if token expired
    // To handle this case InPlayer.Account.getAccount() was used
    const getAccount = await InPlayer.Account.getAccountInfo();

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

export async function login({ email, password, clientId, referrer }) {
  email && (await localStorageSet(IN_PLAYER_LAST_EMAIL_USED_KEY, email));
  try {
    const retVal = await InPlayer.Account.signIn({
      email,
      password,
      clientId,
      referrer,
    });

    logger.debug({
      message: `InPlayer.Account.signIn >> succeed: true, email: ${email}, password: ${password}, in_player_client_id: ${clientId}, referrer: ${referrer}`,
      data: {
        email,
        password,
        in_player_client_id: clientId,
        referrer,
        succeed: true,
      },
    });

    return retVal;
  } catch (error) {
    const { response } = error;

    logger.warning({
      message: `InPlayer.Account.signIn >> status: ${response?.status}, url: ${response?.request?.responseURL}, isAuthenticated: true, email: ${email}, password: ${password}, in_player_client_id: ${clientId}, referrer: ${referrer} `,
      data: {
        email,
        password,
        in_player_client_id: clientId,
        referrer,
        is_authenticated: false,
        error,
      },
    });

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
    logger.debug({
      message: `InPlayer.Account.signUp >> succeed: true, fullName:${fullName}, email: ${email}, password: ${password}, password_confirmation: ${password}, in_player_client_id:${clientId}, referrer: ${referrer}`,
      data: {
        fullName,
        email,
        password,
        password_confirmation: password,
        in_player_client_id: clientId,
        referrer,
        metadata: {},
        type: "consumer",
        succeed: true,
      },
    });

    return retVal;
  } catch (error) {
    logger.warning({
      message: `InPlayer.Account.signIn >> status: ${error?.response?.status}, url: ${error?.response?.request?.responseURL}, succeed: false, fullName: ${fullName}, email: ${email}, password: ${password}, password_confirmation: ${password}, in_player_client_id: ${clientId}, referrer: ${referrer}`,
      data: {
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
      },
    });

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

    logger.debug({
      message: `InPlayer.Account.requestNewPassword >> succeed: true, email: ${email}, in_player_client_id: ${clientId}`,
      data: {
        email,
        in_player_client_id: clientId,
        succeed: true,
      },
    });

    return retVal;
  } catch (error) {
    logger.error({
      message: `InPlayer.Account.requestNewPassword >> status: ${error?.response?.status}, url: ${error?.response?.request?.responseURL}, succeed: false, email: ${email}, in_player_client_id: ${clientId}`,
      data: {
        email,
        in_player_client_id: clientId,
        metadata: ["Dummy"],
        type: "consumer",
        succeed: false,
        error,
      },
    });

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

    logger.debug({
      message: `InPlayer.Account.setNewPassword >> succeed: true, password: ${password}, password_confirmation: ${password}`,
      data: {
        password,
        password_confirmation: password,
        succeed: true,
      },
    });
  } catch (error) {
    logger.error({
      message: `InPlayer.Account.setNewPassword >> status: ${error?.response?.status}, url: ${error?.response?.request?.responseURL}, succeed: false, password: ${password}, password_confirmation: ${password}`,
      data: {
        password,
        password_confirmation: password,
        succeed: false,
        error,
      },
    });

    throw error;
  }
}

export async function signOut() {
  try {
    const retVal = await InPlayer.Account.signOut();

    logger.debug({
      message: `InPlayer.Account.signOut >> succeed: true`,
      data: {
        succeed: true,
      },
    });
    return retVal;
  } catch (error) {
    logger.error({
      message: `InPlayer.Account.signOut >> succeed: false`,
      data: {
        succeed: false,
        error,
      },
    });

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
