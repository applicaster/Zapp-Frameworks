import {
  RequestCustomData,
  SubscriptionsData,
  ExtendTokenData,
  PurchaseItemData,
} from "../../models/Request";
import { OfferItem, TokenData } from "../../models/Response";
import Request from "../../factories/requests";
import { API } from "../../constants";
import {
  localStorageGet,
  localStorageSet,
  localStorageSetUserAccount,
} from "../LocalStorageService";
import { isApplePlatform } from "../../Utils/Platform";
import * as R from "ramda";

import { createLogger, BaseSubsystem, BaseCategories } from "../LoggerService";

export const logger = createLogger({
  subsystem: `${BaseSubsystem}/${BaseCategories.CLEENG_MIDDLEWARE_SERVICE}`,
  category: BaseCategories.CLEENG_MIDDLEWARE_SERVICE,
});

const LOCAL_STORAGE_TOKEN_KEY = "in_player_token";
const USER_ACCOUNT_STORAGE_TOKEN_KEY = "idToken";

export async function prepareMiddleware(data: RequestCustomData) {
  Request.prepare(data);
}

export async function getSubscriptionsData(
  data: SubscriptionsData
): Promise<[OfferItem]> {
  const funcName = "getSubscriptionsData";
  try {
    const byAuthId = 1;
    const newData = {
      ...data,
      byAuthId,
    };
    console.log({ data });
    const response = await Request.post(API.subscriptions, newData);
    const responseData = response?.data;
    logger.debug({
      message: `${funcName} >> succeed: true`,
      data: {
        ...data,
        response,
      },
    });
    return responseData;
  } catch (error) {
    console.log({ error });
    handleError(error, data, funcName);
  }
}

export async function validatePurchasedItem(data: PurchaseItemData) {
  const funcName = "validatePurchasedItem";

  try {
    const appType = isApplePlatform ? "ios" : "android";

    const newData = {
      ...data,
      appType,
    };

    console.log({ data });
    const response = await Request.post(API.purchaseItem, newData);
    const responseData = response?.data;
    logger.debug({
      message: `${funcName} >> succeed: true`,
      data: {
        ...data,
        response,
      },
    });
    return responseData;
  } catch (error) {
    console.log({ error });
    handleError(error, data, funcName);
  }
}

async function verifyPurchase({ payload }) {
  const purchasedItem =
    payload?.extensions?.in_app_purchase_data?.purchasedProduct;
}

export async function getPurchasedAuthIdsAndExtendToken(
  data: ExtendTokenData
): Promise<Array<string>> {
  const funcName = "getPurchasedAuthIdsAndExtendToken";

  try {
    if (!data.token) {
      return null;
    }
    const response = await Request.post(API.extendToken, data);
    const responseData: Array<TokenData> = response?.data;

    let token: string;
    let purchasedAuthIds: Array<string> = [];
    for (const tokenData of responseData) {
      console.log({ tokenData });
      if (tokenData.offerId === "") {
        token = tokenData.token;
      } else {
        purchasedAuthIds.push(tokenData.authId);
      }
    }
    console.log({ token, purchasedAuthIds });
    if (token) {
      await setToken(token);
    }

    logger.debug({
      message: `${funcName} >> succeed: true`,
      data: {
        ...data,
        response,
      },
    });

    return purchasedAuthIds;
  } catch (error) {
    handleError(error, data, funcName, false);
    return null;
  }
}

function handleError(
  error,
  data,
  funcName: string,
  throwError: boolean = true
) {
  const responseData = error?.response?.data;
  const response_url = error?.response?.request?.responseURL;
  logger.error({
    message: `${funcName} >> succeed: false, status: ${responseData?.code}, message: ${responseData?.message}, url: ${response_url}`,
    data: {
      ...data,
      response_url,
      error,
    },
  });
  if (throwError) {
    throw error;
  }
}

export async function getToken() {
  return localStorageGet(LOCAL_STORAGE_TOKEN_KEY);
}

export async function setToken(token: string) {
  await localStorageSet(LOCAL_STORAGE_TOKEN_KEY, token);
  await localStorageSetUserAccount(USER_ACCOUNT_STORAGE_TOKEN_KEY, token);
}
