import * as R from "ramda";
import InPlayer from "@inplayer-org/inplayer.js";
import { checkStatus, params, errorResponse } from "./InPlayerUtils";
import {
  getSrcFromAsset,
  getCookiesFromAsset,
} from "../Utils/OVPProvidersMapper";
import { localStorage } from "../LocalStorageHack";
import { assetPaymentRequired, externalAssetData } from "../Utils/PayloadUtils";
import { externalPurchaseValidationURL } from "./InPlayerServiceHelper";
import { isAmazonPlatform } from "./../Utils/Platform";
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

export async function setConfig(environment = "prod") {
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

      const retVal = result?.id;
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
    const src = getSrcFromAsset(asset);
    const cookies = getCookiesFromAsset(asset);
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
    const event = logger
      .createEvent()
      .addData({
        response: error?.response,
        is_purchase_required: false,
        error,
      })
      .attachError(error);

    if (retryInCaseFail && tries > 0) {
      await new Promise((r) => setTimeout(r, interval));
      const newInterval = interval * 2;
      const newTries = tries - 1;
      event
        .setMessage(
          `InPlayer.Asset.checkAccessForAsset Failed >> status: ${error?.response?.status}, url: ${error?.response?.url} >> retry to load`
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
            `InPlayer.Asset.checkAccessForAsset >> status: ${error?.response?.status}, url: ${error?.response?.url}, is_purchase_required: ${isPurchaseRequired}`
          )
          .setLevel(XRayLogLevel.debug)
          .send();

        throw { ...error, requestedToPurchase: isPurchaseRequired };
      }
      event
        .setMessage(
          `InPlayer.Asset.checkAccessForAsset Failed >> status: ${error?.response?.status}, url: ${error?.response?.url}`
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
    const descriptions = R.map(R.prop("description"))(retVal);
    logger
      .createEvent()
      .setMessage(
        `InPlayer.Asset.getAssetAccessFees Completed >> inplayer_asset_id: ${assetId} >> fees_count: ${retVal.length}, fee_descriptions: ${descriptions}`
      )
      .setLevel(XRayLogLevel.debug)
      .addData({
        inplayer_asset_access_fees: retVal,
        inplayer_asset_id: assetId,
      })
      .send();
    return retVal;
  } catch (error) {
    logger
      .createEvent()
      .setMessage(
        `InPlayer.Asset.getAssetAccessFees Failed >> status: ${error?.response?.status}, url: ${error?.response?.url}, inplayer_asset_id: ${assetId}`
      )
      .setLevel(XRayLogLevel.error)
      .addData({
        inplayer_asset_id: assetId,
      })
      .attachError(error)
      .send();
    throw error;
  }
}

export function getAllPackages({ in_player_client_id }) {
  logger
    .createEvent()
    .setMessage(
      `InPlayer.Asset.getPackage >> inplayer_asset_id: ${in_player_client_id}`
    )
    .setLevel(XRayLogLevel.debug)
    .addData({
      in_player_client_id,
    })
    .send();

  return InPlayer.Asset.getPackage(in_player_client_id)
    .then((packagesList) => {
      const collection = packagesList.collection;
      const titles = R.map(R.prop("title"))(collection);
      logger
        .createEvent()
        .setMessage(
          `InPlayer.Asset.getPackage Completed >> inplayer_asset_id: ${in_player_client_id} >> packages_count: ${collection.length}, titles: ${titles}`
        )
        .setLevel(XRayLogLevel.debug)
        .addData({
          in_player_client_id,
          collection,
          packages_list: packagesList,
        })
        .send();

      return collection;
    })
    .then(loadAllPackages)
    .catch((error) => {
      logger
        .createEvent()
        .setMessage(
          `InPlayer.Asset.getPackage Failed >> status: ${error?.response?.status}, url: ${error?.response?.url}, inplayer_asset_id: ${in_player_client_id}`
        )
        .setLevel(XRayLogLevel.error)
        .addData({
          in_player_client_id,
        })
        .attachError(error)
        .send();
      throw error;
    });
}

export async function loadAllPackages(collection) {
  const titles = R.map(R.prop("title"))(collection);

  logger
    .createEvent()
    .setMessage(
      `loadAllPackages >> packages_count: ${collection.length}, packages_titles: ${titles}`
    )
    .setLevel(XRayLogLevel.debug)
    .addData({
      collection,
    })
    .send();

  const promises = collection.map((item) => {
    return InPlayer.Asset.getPackage(item.id);
  });
  try {
    const retVal = await Promise.all(promises);
    logger
      .createEvent()
      .setMessage(
        `InPlayer.Asset.getPackage Completed >> All Package Loaded >> packages_count: ${retVal.length}, packages_titles: ${titles}`
      )
      .setLevel(XRayLogLevel.debug)
      .addData({
        collection,
      })
      .send();
    return retVal;
  } catch (error) {
    logger
      .createEvent()
      .setMessage(
        `InPlayer.Asset.getPackage Failed >> status: ${error?.response?.status}, url: ${error?.response?.url}, packages_count: ${titles.length}, packages_titles: ${titles}`
      )
      .setLevel(XRayLogLevel.error)
      .addData({
        collection,
      })
      .attachError(error)
      .send();
    throw error;
  }
}

export async function isAuthenticated(in_player_client_id) {
  try {
    // InPlayer.Account.isAuthenticated() returns true even if token expired
    // To handle this case InPlayer.Account.getAccount() was used
    await InPlayer.Account.getAccount();
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
    const res = await error.response.json();

    if (res?.code === 403) {
      await InPlayer.Account.refreshToken(in_player_client_id);
      logger
        .createEvent()
        .setMessage(
          `InPlayer.Account.getAccount >> status: ${res?.code}, is_authenticated: true`
        )
        .setLevel(XRayLogLevel.error)
        .addData({
          in_player_client_id,
          is_authenticated: true,
        })
        .attachError(error)
        .send();
      return true;
    }

    logger
      .createEvent()
      .setMessage(
        `InPlayer.Account.getAccount >> status: ${res?.code}, is_authenticated: false`
      )
      .setLevel(XRayLogLevel.error)
      .addData({
        in_player_client_id,
        is_authenticated: false,
      })
      .attachError(error)
      .send();
    return false;
  }
}

export async function login({ email, password, clientId, referrer }) {
  email && (await localStorage.setItem(IN_PLAYER_LAST_EMAIL_USED_KEY, email));
  try {
    const retVal = await InPlayer.Account.authenticate({
      email,
      password,
      clientId,
      referrer,
    });
    logger
      .createEvent()
      .setMessage(
        `InPlayer.Account.authenticate >> succeed: true, email: ${email}, password: ${password}, in_player_client_id:${clientId}, referrer: ${referrer}`
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
    if (response && response.status == 403) {
      const refreshToken = response.headers.get("x-inplayer-token");
      const retVal = await InPlayer.Account.authenticate({
        refreshToken,
        clientId,
        referrer,
      });

      logger
        .createEvent()
        .setMessage(
          `InPlayer.Account.authenticate with refresh_token >> succeed: true, email: ${email}, password: ${password}, in_player_client_id:${clientId}, referrer: ${referrer}`
        )
        .setLevel(XRayLogLevel.debug)
        .addData({
          email,
          password,
          in_player_client_id: clientId,
          referrer,
          refreshToken,
          succeed: true,
        })
        .send();

      return retVal;
    } else {
      logger
        .createEvent()
        .setMessage(
          `InPlayer.Account.authenticate >> status: ${response?.status}, url: ${response?.url}, isAuthenticated: true, email: ${email}, password: ${password}, in_player_client_id:${clientId}, referrer: ${referrer} `
        )
        .setLevel(XRayLogLevel.error)
        .addData({
          email,
          password,
          in_player_client_id: clientId,
          referrer,
          is_authenticated: false,
        })
        .attachError(error)
        .send();
      throw error;
    }
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
        `InPlayer.Account.authenticate >> status: ${error?.response?.status}, url: ${error?.response?.url}, succeed: false, fullName:${fullName}, email: ${email}, password: ${password}, password_confirmation: ${password}, in_player_client_id:${clientId}, referrer: ${referrer}`
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
      })
      .attachError(error)
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
        `InPlayer.Account.requestNewPassword >> succeed: true, email: ${email}, in_player_client_id:${clientId}`
      )
      .setLevel(XRayLogLevel.debug)
      .addData({ email, in_player_client_id: clientId, succeed: true })
      .send();
    return retVal;
  } catch (error) {
    logger
      .createEvent()
      .setMessage(
        `InPlayer.Account.requestNewPassword >> status: ${error?.response?.status}, url: ${error?.response?.url}, succeed: false, email: ${email}, in_player_client_id:${clientId}`
      )
      .setLevel(XRayLogLevel.error)
      .addData({
        email,
        in_player_client_id: clientId,
        metadata: ["Dummy"],
        type: "consumer",
        succeed: false,
      })
      .attachError(error)
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
        `InPlayer.Account.setNewPassword >> succeed: true, password: ${password}, password_confirmation:${password}`
      )
      .setLevel(XRayLogLevel.debug)
      .addData({ password, password_confirmation: password, succeed: true })
      .send();
  } catch (error) {
    logger
      .createEvent()
      .setMessage(
        `InPlayer.Account.setNewPassword >> status: ${error?.response?.status}, url: ${error?.response?.url}, succeed: false, password: ${password}, password_confirmation:${password}`
      )
      .setLevel(XRayLogLevel.error)
      .addData({
        password,
        password_confirmation: password,
        succeed: false,
      })
      .attachError(error)
      .send();
    throw error;
  }
}

export async function signOut() {
  if (!InPlayer.Account.isAuthenticated()) {
    return false;
  } else {
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
        })
        .attachError(error)
        .send();
      throw error;
    }
  }
}

export async function getLastEmailUsed() {
  return localStorage.getItem(IN_PLAYER_LAST_EMAIL_USED_KEY);
}

function extraValidationPaymentParams({ userId, store }) {
  return isAmazonPlatform(store) ? { amazon_user_id: userId } : {};
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

  if (isAmazonPlatform(store)) {
    event.addData({
      amazon_user_id: userId,
    });
  }

  const validationURL = store && externalPurchaseValidationURL(store);
  let request = null;
  try {
    if (!validationURL) {
      throw new Error("Can not retrieve validation url");
    }

    if (!InPlayer.Account.isAuthenticated()) {
      errorResponse(401, {
        code: 401,
        message: "User is not authenticated",
      });
    }

    if (!receipt) {
      throw new Error("Payment receipt is a required parameter!");
    }
    if (!item_id) {
      throw new Error("Payment item_id is a required parameter!");
    }
    if (!access_fee_id) {
      throw new Error("Payment access_fee_id is a required parameter!");
    }

    let body = {
      receipt,
      item_id,
      access_fee_id,
      ...extraValidationPaymentParams({ userId, store }),
    };

    request = {
      method: "POST",
      headers: {
        Authorization: `Bearer ${InPlayer.Account.getToken().token}`,
        "Content-Type": "application/x-www-form-urlencoded",
        Accept: "application/json",
      },
      body: params(body),
    };

    event.addData({
      validation_url: validationURL,
      body,
      request,
    });

    const response = await fetch(validationURL, request);
    event.addData({
      response,
    });

    checkStatus(response);
    const retVal = await response.json();
    event
      .addData({
        parsed_response: retVal,
      })
      .setMessage(
        `InPlayer validate external payment >> succeed: true, url:${validationURL}`
      )
      .send();

    return retVal;
  } catch (error) {
    event
      .setMessage(
        `InPlayer validate external payment >> succeed: false, url:${validationURL}`
      )
      .setLevel(XRayLogLevel.error)
      .attachError(error)
      .addData({
        error,
        response: error?.response,
      })
      .send();
    throw error;
  }
}

// Currently is not working
export function unsubscribeNotifications() {
  InPlayer.unsubscribe();
}

// Currently is not working
export async function subscribeNotifications({ clientId, callbacks }) {
  const iotData = await InPlayer.Notifications.getIotToken();

  return await InPlayer.Notifications.handleSubscribe(
    iotData,
    callbacks,
    clientId
  );
}
