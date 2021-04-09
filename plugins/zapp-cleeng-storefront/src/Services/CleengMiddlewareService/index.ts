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
import { getArraysIntersection } from "../../Utils/DataHelper";

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
    const response = await Request.post(API.subscriptions, newData);
    const responseData = response?.data;
    logger.debug({
      message: `${funcName} >> succeed: true`,
      data: {
        ...newData,
        response,
      },
    });
    return responseData;
  } catch (error) {
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

    const response = await Request.post(API.purchaseItem, newData);
    const responseData = response?.data;
    logger.debug({
      message: `${funcName} >> succeed: true`,
      data: {
        ...newData,
        response,
      },
    });
    return responseData;
  } catch (error) {
    handleError(error, data, funcName);
  }
}

export async function isItemsPurchased(
  offers: Array<string>,
  token: string,
  publisherId: string
): Promise<boolean> {
  const funcName = "isItemsPurchased";

  try {
    const purchasedAuthIds = await getPurchasedAuthIdsAndExtendToken({
      token,
      publisherId,
    });

    const isPurchased = getArraysIntersection(offers, purchasedAuthIds);
    logger.debug({
      message: `${funcName} >> succeed: true`,
      data: {
        purchased_auth_ids: purchasedAuthIds,
        is_purchased: isPurchased,
      },
    });

    return isPurchased;
  } catch (error) {
    handleError(error, { offers, token, publisherId }, funcName, false);
  }
}

export async function isItemsPurchasedRecursive(
  offers: Array<string>,
  token: string,
  publisherId: string,
  tries = 3
): Promise<boolean> {
  const funcName = "isItemsPurchasedRecursive";
  try {
    const interval = 5000;

    const purchasedAuthIds = await getPurchasedAuthIdsAndExtendToken({
      token,
      publisherId,
    });
    const result = getArraysIntersection(offers, purchasedAuthIds);

    if (result === false && tries > 0) {
      await new Promise((r) => setTimeout(r, interval));
      const newTries = tries - 1;
      return await isItemsPurchasedRecursive(
        offers,
        token,
        publisherId,
        newTries
      );
    } else {
      return result;
    }
  } catch (error) {
    handleError(error, { offers, token, publisherId, tries }, funcName, false);
  }
}

export async function verifyPurchase(
  payload: ZappEntry,
  token: string,
  publisherId: string,
  isRestored: boolean
) {
  const funcName = "verifyPurchase";

  try {
    const productToPurchase =
      payload?.extensions?.in_app_purchase_data?.productsToPurchase;

    const purchasedProduct =
      payload?.extensions?.in_app_purchase_data?.purchasedProduct;

    const productIdentifier = purchasedProduct?.productIdentifier;

    const receiptData = purchasedProduct?.receipt;
    const transactionId = purchasedProduct?.transactionIdentifier;

    const offerId = R.find(R.propEq("productIdentifier", productIdentifier))(
      productToPurchase
    )?.id;
    const authId = R.find(R.propEq("productIdentifier", productIdentifier))(
      productToPurchase
    )?.authId;
    if (offerId && productIdentifier && receiptData && transactionId) {
      const data = isApplePlatform ? { receiptData } : JSON.parse(receiptData);

      const result = await validatePurchasedItem({
        token,
        offerId,
        publisherId,
        isRestored,
        receipt: { transactionId, ...data },
      });
      const validateResult = await checkValidatedItem({
        token,
        publisherId,
        authId: authId,
      });
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
  } catch (error) {
    handleError(error, { payload, publisherId, isRestored }, funcName);
  }
}

export async function checkValidatedItem({
  authId,
  token,
  publisherId,
  tries = 5,
}): Promise<boolean> {
  const interval = 5000;
  const funcName = "checkValidatedItem";
  try {
    const purchasedAuthIds = await getPurchasedAuthIdsAndExtendToken({
      token,
      publisherId,
    });

    if (R.contains(authId, purchasedAuthIds)) {
      logger.debug({
        message: `${funcName} >> succeed: true`,
        data: {
          authId,
          token,
          publisher_id: publisherId,
        },
      });
      return true;
    } else if (tries > 0) {
      await new Promise((r) => setTimeout(r, interval));
      const newTries = tries - 1;
      logger.debug({
        message: `${funcName} >> can not find any items purchased items, trying check again`,
        data: {
          authId,
          token,
          publisher_id: publisherId,
          new_tries: newTries,
        },
      });
      return await checkValidatedItem({
        authId,
        token,
        publisherId,
        tries: newTries,
      });
    } else {
      logger.debug({
        message: `${funcName} >> can not find any items purchased items, checking stopped with error`,
        data: {
          authId,
          token,
          publisher_id: publisherId,
        },
      });
      const error = new Error("Can not validate purchased items");
      handleError(error, { authId, publisherId }, funcName);
    }
  } catch (error) {
    handleError(error, { authId, token, publisherId, tries }, funcName);
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
      if (tokenData.offerId === "") {
        token = tokenData.token;
      } else {
        purchasedAuthIds.push(tokenData.authId);
      }
    }
    if (token) {
      await setToken(token);
    }

    logger.debug({
      message: `${funcName} >> succeed: true`,
      data: {
        ...data,
        response,
        token,
        purchased_auth_ids: purchasedAuthIds,
      },
    });

    return purchasedAuthIds;
  } catch (error) {
    handleError(error, data, funcName);
  }
}

export function isRestoreEmpty(data) {
  if (isApplePlatform) {
    const products = data?.products;
    if (products && products?.length > 0) {
      return false;
    }
    return true;
  } else {
    if (data && data?.length > 0) {
      return false;
    }
    return true;
  }
}

export async function restorePurchases(data: RestoreData) {
  const funcName = "restorePurchases";
  const token = data?.token;
  const publisherId = data.publisherId;
  const offers = data.offers;
  function iOSData() {
    const receiptData = data?.restoreData?.receipt;
    const products = data?.restoreData?.products;
    const receipts = R.map((item) => {
      return {
        transactionId: item.transactionIdentifier,
        productId: item.productIdentifier,
      };
    })(products);
    return {
      receiptData,
      receipts,
    };
  }

  function androidData() {
    const receiptData = data?.restoreData;
    const receipts = R.map((item) => {
      const parsedReciept = JSON.parse(item.receipt);
      return parsedReciept;
    })(receiptData);
    return { receipts };
  }

  const customData = isApplePlatform ? iOSData() : androidData();
  try {
    if (!data.token) {
      return null;
    }
    const response = await Request.post(API.restore, {
      publisherId,
      token,
      ...customData,
    });

    const result = isItemsPurchasedRecursive(offers, token, publisherId);
    logger.debug({
      message: `${funcName} >> succeed: true`,
      data: {
        ...data,
        ...customData,
        response,
        result,
      },
    });

    return result;
  } catch (error) {
    handleError(error, data, funcName, true);
  }
}

function handleError(
  error,
  data,
  funcName: string,
  throwError: boolean = true
) {
  const message = error?.response?.data?.message || "No Message";
  const response_url = error?.response?.request?.responseURL || "No URL";

  logger.error({
    message: `${funcName} >> succeed: false, message: ${message}, url: ${response_url}`,
    data: {
      ...data,
      error,
      throw_error: throwError,
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
