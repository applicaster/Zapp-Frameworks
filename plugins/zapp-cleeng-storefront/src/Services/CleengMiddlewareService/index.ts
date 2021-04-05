import {
  RequestCustomData,
  SubscriptionsData,
  ExtendTokenData,
  PurchaseItemData,
  RestoreData,
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
import { ViewPagerAndroidComponent } from "react-native";

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
  console.log({ data, funcName });
  try {
    const appType = isApplePlatform ? "ios" : "android";

    const newData = {
      ...data,
      appType,
    };

    console.log({ data });
    const response = await Request.post(API.purchaseItem, newData);
    console.log({ response });
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
    console.log("validatePurchasedItem", { error });
    handleError(error, data, funcName);
  }
}

function getArraysIntersection(a1: Array<string>, a2: Array<string>) {
  if (!a1 || !a2 || a1.length === 0 || a2.length === 0) {
    return false;
  }
  const result = a1.filter(function (n) {
    return a2.indexOf(n) !== -1;
  });
  console.log({ result });
  return result.length > 0 ? true : false;
}

export async function isItemsPurchased(
  offers: Array<string>,
  token: string,
  publisherId: string
): Promise<boolean> {
  const purchasedAuthIds = await getPurchasedAuthIdsAndExtendToken({
    token,
    publisherId,
  });
  console.log({ purchasedAuthIds, offers });
  return getArraysIntersection(offers, purchasedAuthIds);
}

export async function isItemsPurchasedRecursive(
  offers: Array<string>,
  token: string,
  publisherId: string,
  tries = 5
): Promise<boolean> {
  const interval = 5000;

  const purchasedAuthIds = await getPurchasedAuthIdsAndExtendToken({
    token,
    publisherId,
  });
  console.log({ purchasedAuthIds, offers });
  const result = getArraysIntersection(offers, purchasedAuthIds);

  if (result === false && tries > 0) {
    await new Promise((r) => setTimeout(r, interval));
    tries = tries - 1;
  } else {
    return result;
  }
}

export async function verifyPurchase(
  payload: ZappEntry,
  token: string,
  publisherId: string,
  isRestored: boolean
) {
  const funcName = "verifyPurchase";
  console.log({ payload });
  const productToPurchase =
    payload?.extensions?.in_app_purchase_data?.productsToPurchase;
  console.log({ productToPurchase });

  const purchasedProduct =
    payload?.extensions?.in_app_purchase_data?.purchasedProduct;
  console.log({ purchasedProduct });

  const productIdentifier = purchasedProduct?.productIdentifier;
  const receiptData = purchasedProduct?.receipt;
  const transactionId = purchasedProduct?.transactionIdentifier;
  const offerId = R.find(R.propEq("productIdentifier", productIdentifier))(
    productToPurchase
  )?.id;
  const authId = R.find(R.propEq("productIdentifier", productIdentifier))(
    productToPurchase
  )?.authId;
  console.log({ offerId, productIdentifier, receiptData, transactionId });
  if (offerId && productIdentifier && receiptData && transactionId) {
    const result = await validatePurchasedItem({
      token,
      offerId,
      publisherId,
      isRestored,
      receipt: { transactionId, receiptData },
    });
    console.log(" validatePurchasedItem", { result });
    const validateResult = await checkValidatedItem({
      token,
      publisherId,
      authId: authId,
    });
    console.log("validateResult", { validateResult });
    logger.debug({
      message: `${funcName} >> succeed: true`,
      data: {
        result,
        token,
        publisher_id: publisherId,
        validate_result: validateResult,
      },
    });
    return validateResult;
  }
  const error = new Error("Required paramenters not exist");
  handleError(error, { payload, publisherId, isRestored }, funcName);
}

export async function checkValidatedItem({
  authId,
  token,
  publisherId,
  tries = 5,
  interval = 5000,
}): Promise<boolean> {
  console.log({ authId, token, publisherId });
  const funcName = "checkValidatedItem";
  try {
    const purchasedAuthIds = await getPurchasedAuthIdsAndExtendToken({
      token,
      publisherId,
    });
    console.log({ purchasedAuthIds });

    if (R.contains(authId, purchasedAuthIds)) {
      console.log("Finished!!!!!");
      return true;
    } else if (tries > 0) {
      await new Promise((r) => setTimeout(r, interval));
      const newTries = tries - 1;
      await checkValidatedItem({
        authId,
        token,
        publisherId,
        tries: newTries,
        interval,
      });
      logger.debug({
        message: `${funcName} >> succeed: true`,
        data: {
          authId,
          token,
          publisher_id: publisherId,
          new_tries: newTries,
        },
      });
    } else {
      const error = new Error("Can not validate purchased items");
      handleError(error, { authId, publisherId }, funcName);
    }
  } catch (error) {
    throw error;
  }
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
    handleError(error, data, funcName);
  }
}

export async function restorePurchases(data: RestoreData) {
  const funcName = "restorePurchases";
  const token = data?.token;
  const reciept = data?.restoreData?.receipt;
  const publisherId = data.publisherId;
  const offers = data.offers;
  const reciepts = R.map((item) => {
    return {
      transactionId: item.transactionIdentifier,
      productId: item.productIdentifier,
    };
  })(data?.restoreData?.products);
  console.log({ token, reciept, reciepts });
  try {
    if (!data.token) {
      return null;
    }
    const response = await Request.post(API.restore, {
      token,
      reciept,
      reciepts,
    });

    const result = isItemsPurchasedRecursive(offers, token, publisherId);
    logger.debug({
      message: `${funcName} >> succeed: true`,
      data: {
        ...data,
        response,
        result,
      },
    });

    return result;
  } catch (error) {
    handleError(error, data, funcName);
  }
}

function handleError(
  error,
  data,
  funcName: string,
  throwError: boolean = true
) {
  console.log({ error, data, funcName, throwError });
  const message = error?.response?.data?.message || "No Message";
  const response_url = error?.response?.request?.responseURL || "No URL";

  logger.error({
    message: `${funcName} >> succeed: false, message: ${message}, url: ${response_url}`,
    data: {
      ...data,
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
