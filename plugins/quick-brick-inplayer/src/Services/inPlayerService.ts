import * as R from "ramda";
import InPlayer, {
  CommonResponse,
  CreateAccount,
  GetAccessFee,
  GetItemAccessV1,
  ReceiptValidationPlatform,
  ValidateReceiptData,
} from "@inplayer-org/inplayer.js";

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
import { AxiosError } from "axios";

export const logger = createLogger({
  subsystem: `${BaseSubsystem}/${BaseCategories.INPLAYER_SERVICE}`,
  category: BaseCategories.INPLAYER_SERVICE,
});

const IN_PLAYER_LAST_EMAIL_USED_KEY = "com.inplayer.lastEmailUsed";

export declare type AssetForAssetResult = {
  asset: GetItemAccessV1;
  src: string;
  cookies: any;
};

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

export async function getAssetIdByExternalId(
  payload: ZappEntry
): Promise<number> {
  const assetData = externalAssetData(payload);
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

      const axiosResult = await InPlayer.Asset.getExternalAsset(
        inplayerAssetType,
        externalAssetId.toString(),
        null
      );
      const result = axiosResult?.data;

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
      return null;
    }
  } else {
    errorEvent.send();
    return null;
  }
}

export async function checkAccessForAsset({
  assetId,
  retryInCaseFail,
  interval = 1000,
  tries = 5,
}: AssetForAssetParams): Promise<AssetForAssetResult> {
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
    const axiosAsset = await InPlayer.Asset.checkAccessForAsset(assetId);
    const asset = axiosAsset?.data;
    console.log({ asset });
    const src = getSrcFromAsset(asset);
    console.log({ src });

    const cookies = getCookiesFromAsset(asset);
    console.log({ cookies });

    logger
      .createEvent()
      .setMessage(
        `InPlayer.Asset.checkAccessForAsset Completed >> inplayer_asset_id: ${assetId} >> title: ${asset?.item.title} src: ${src}`
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
        assetId: assetId,
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

export async function getAccessFees(assetId: number): Promise<GetAccessFee> {
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

    const axiosAccessFees = await InPlayer.Asset.getAssetAccessFees(assetId);
    const accessFees = axiosAccessFees?.data;
    console.log({ acessFeesResult: accessFees });
    const descriptions = R.map(R.prop("description"))(accessFees);
    logger
      .createEvent()
      .setMessage(
        `InPlayer.Asset.getAssetAccessFees Completed >> inplayer_asset_id: ${assetId} >> fee_descriptions: ${descriptions}`
      )
      .setLevel(XRayLogLevel.debug)
      .addData({
        inplayer_asset_access_fees: accessFees,
        inplayer_asset_id: assetId,
      })
      .send();
    return accessFees;
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

export async function isAuthenticated(
  in_player_client_id: string
): Promise<boolean> {
  try {
    // InPlayer.Account.isAuthenticated() returns true even if token expired
    // To handle this case InPlayer.Account.getAccount() was used
    await InPlayer.Account.getAccountInfo();

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

export async function login({
  email,
  password,
  clientId,
  referrer,
}: LoginParams): Promise<CreateAccount> {
  email && (await localStorageSet(IN_PLAYER_LAST_EMAIL_USED_KEY, email));
  try {
    const axiosResponse = await InPlayer.Account.signIn({
      email,
      password,
      clientId,
      referrer,
    });
    const response = axiosResponse?.data;
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
    return response;
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

export async function signUp({
  fullName,
  email,
  password,
  clientId,
  referrer,
  brandingId,
}: SignUpParams): Promise<CreateAccount> {
  try {
    const axiosResponse = await InPlayer.Account.signUp({
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
    const response = axiosResponse?.data;
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
    return response;
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

export async function requestPassword({
  email,
  clientId,
  brandingId,
}: RequestNewPasswordParams): Promise<CommonResponse> {
  try {
    const axiosResponse = await InPlayer.Account.requestNewPassword({
      email,
      merchantUuid: clientId,
      brandingId,
    });
    const response = axiosResponse?.data;
    logger
      .createEvent()
      .setMessage(
        `InPlayer.Account.requestNewPassword >> succeed: true, email: ${email}, in_player_client_id: ${clientId}`
      )
      .setLevel(XRayLogLevel.debug)
      .addData({ email, in_player_client_id: clientId, succeed: true })
      .send();
    return response;
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

export async function setNewPassword({
  password,
  token,
  brandingId,
}: SetNewPasswordParams) {
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

export async function getLastEmailUsed(): Promise<string> {
  return localStorageGet(IN_PLAYER_LAST_EMAIL_USED_KEY);
}

//TODO: This func not working with Web, implement proper way in future
export async function validateExternalPayment({
  receipt,
  userId,
  item_id,
  access_fee_id,
  store,
}: ValidateExternalPaymentParams) {
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

    const amazonUserId = isAmazonPlatform(store) ? userId : null;

    let recieptData: ValidateReceiptData = null;
    if (isAmazonPlatform(store)) {
      recieptData = {
        accessFeeId: access_fee_id,
        amazonUserId,
        itemId: item_id,
        platform: ReceiptValidationPlatform.AMAZON,
        receipt,
      };
      event.addData({
        amazon_user_id: userId,
      });
    } else if (isAndroidPlatform) {
      recieptData = {
        accessFeeId: access_fee_id,
        itemId: item_id,
        platform: ReceiptValidationPlatform.GOOGLE_PLAY,
        receipt,
      };
    } else if (isApplePlatform) {
      recieptData = {
        accessFeeId: access_fee_id,
        itemId: item_id,
        platform: ReceiptValidationPlatform.APPLE,
        receipt,
      };
    } else {
      throw new Error("Platform can not be received");
    }

    const axiosResponse = await InPlayer.Payment.validateReceipt(recieptData);
    const response = axiosResponse.data;

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
