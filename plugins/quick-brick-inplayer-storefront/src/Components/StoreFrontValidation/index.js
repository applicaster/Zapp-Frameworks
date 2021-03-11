import * as R from "ramda";
import { validateExternalPayment } from "../../Services/inPlayerService";
import { createLogger, Subsystems } from "../../Services/LoggerService";
import { findAsync } from "../../Services/InPlayerUtils";
import { isAndroidPlatform, isApplePlatform } from "../../Utils/Platform";
export const logger = createLogger({
  subsystem: Subsystems.STOREFRONT_VALIDATION,
});
import MESSAGES from "../Config";

export async function validatePayment(props) {
  console.log("validatePayment", { props });

  const payload = props?.payload;
  const store = props?.store;
  const purchasedItem =
    payload?.extensions?.in_app_purchase_data?.purchasedProduct;
  const inPlayerData = payload?.extensions?.in_player_data;
  const inPlayerFeesData = inPlayerData?.inPlayerFeesData;
  console.log({ inPlayerData, inPlayerFeesData });
  const purchasedProductIdentifier = purchasedItem?.productIdentifier;

  const feeData = feeDataForPurchase({
    purchasedProductIdentifier,
    inPlayerFeesData,
  });
  const fee = feeData?.fee;
  console.log({ fee });

  await validatePurchase({ purchasedItem, fee, store });
}

async function validatePurchase({ purchasedItem, fee, store }) {
  // Currently only avail for amazon, rest platform currently does not support this key
  const amazon_user_id = purchasedItem?.userId;
  console.log({ purchasedItem, fee, store });
  if (fee && purchasedItem) {
    const id = fee?.id;
    const itemId = fee?.item_id;
    const receipt = purchasedItem?.receipt;
    console.log({
      purchasedItem,
      fee,
      store,
      validateExternalPayment,
      id,
      itemId,
    });

    if (id && itemId && receipt && store) {
      console.log({
        receipt,
        amazon_user_id,
        itemId,
        id,
        store,
      });
      const result = await validateExternalPayment({
        receipt,
        amazon_user_id,
        item_id: itemId,
        access_fee_id: id,
        store,
      });
      logger.debug({
        message: "validateExternalPayment: Success",
        data: {
          receipt,
          amazon_user_id,
          item_id: itemId,
          access_fee_id: id,
          store,
        },
      });
      return result;
    }
  }
  throw new Error(
    "Can not validate purchase data is missing, check purchasedItem and fee"
  );
}

function feeDataForPurchase({ purchasedProductIdentifier, inPlayerFeesData }) {
  console.log({ purchasedProductIdentifier, inPlayerFeesData });

  return R.find(R.propEq("storePurchaseID", purchasedProductIdentifier))(
    inPlayerFeesData
  );
}

export async function validateRestore(props) {
  try {
    const restoreData = props?.restoreData;
    if (restoreData) {
      const payload = props?.payload;
      const store = props?.store;

      const inPlayerData = payload?.extensions?.in_player_data;
      const inPlayerFeesData = inPlayerData?.inPlayerFeesData;
      console.log({ props, restoreData, inPlayerFeesData });

      if (isAndroidPlatform) {
        restoreData = R.uniqWith(R.eqProps, restoreData);
      } else if (isApplePlatform) {
        restoreData.restoredProducts = R.uniqWith(
          R.eqProps,
          restoreData.restoredProducts
        );
      }
      console.log({ restoreData });
      const promises = inPlayerFeesData.map(async (feeData) => {
        return await restoreAnItem({ feeData, restoreData, store });
      });

      const restoreCompletionsArr = await Promise.all(promises);

      const restoreProcessedArr = restoreCompletionsArr.filter(Boolean);

      const isRestoreFailed = R.isEmpty(restoreProcessedArr);
      console.log({ isRestoreFailed });
      const isErrorOnAllRestores = restoreProcessedArr.every(
        ({ success }) => success === false
      );
      console.log({ isErrorOnAllRestores, restoreProcessedArr });

      if (isRestoreFailed) throw new Error(MESSAGES.restore.empty);

      if (isErrorOnAllRestores) throw new Error(restoreProcessedArr[0].message);
    }
  } catch (error) {
    throw error;
  }
}

async function restoreAnItem({ feeData, restoreData, store }) {
  const fee = feeData?.fee;
  const purchaseID = feeData?.storePurchaseID;
  const id = fee?.id.toString();
  const itemId = fee?.item_id.toString();
  console.log({ fee, purchaseID, id, itemId });
  const itemFromStoreResult = isAndroidPlatform
    ? await findItemInRestoreAndroid(purchaseID, restoreData)
    : await findItemInRestoreIos(purchaseID, restoreData);

  if (!itemFromStoreResult) return false;

  // Currently only avail for amazon, rest platform currently does not support this key
  const amazon_user_id = itemFromStoreResult?.userId;

  logger.debug({
    message: `Restore item - purchase_id: ${purchaseID}`,
    data: {
      purchase_id: purchaseID,
      restore_data: restoreData,
      receipt: itemFromStoreResult?.receipt,
      amazon_user_id,
      item_id: itemId,
      access_fee_id: id,
      store,
    },
  });
  console.log({
    purchase_id: purchaseID,
    restore_data: restoreData,
    receipt: itemFromStoreResult?.receipt,
    amazon_user_id,
    item_id: itemId,
    access_fee_id: id,
    store,
  });
  try {
    const result = await validateExternalPayment({
      receipt: itemFromStoreResult?.receipt,
      amazon_user_id,
      item_id: itemId.toString(),
      access_fee_id: id.toString(),
      store,
    });

    logger.debug({
      message: `Restore item - completed, purchase_id: ${purchaseID}`,
      data: {
        purchase_id: purchaseID,
        restore_data: restoreData,
        receipt: itemFromStoreResult?.receipt,
        amazon_user_id,
        item_id: itemId,
        access_fee_id: id,
        store,
      },
    });

    return result;
  } catch (error) {
    logger.error({
      message: `Restore item - purchase_id: ${purchaseID} >> error message:${error.message}`,
      data: {
        purchase_id: purchaseID,
        restore_data: restoreData,
        error,
      },
    });
    return {
      code: error?.response?.status,
      success: false,
      message: MESSAGES.restore.failInfo,
    };
  }
}

async function findItemInRestoreAndroid(purchaseIdInPlayer, restoreData) {
  if (R.isEmpty(restoreData)) return false;

  const itemFromRestore = await findAsync(
    restoreData,
    async ({ productIdentifier }) => {
      return productIdentifier === purchaseIdInPlayer;
    }
  );
  return itemFromRestore?.receipt ? itemFromRestore : false;
}

async function findItemInRestoreIos(purchaseIdInPlayer, restoreData) {
  const restoredProductsIdArr = restoreData?.restoredProducts;
  if (R.isEmpty(restoredProductsIdArr)) return false;

  const productIdFromRestore = await findAsync(
    restoredProductsIdArr,
    async (productIdentifier) => {
      return productIdentifier === purchaseIdInPlayer;
    }
  );

  const itemInRestore = {
    productIdentifier: productIdFromRestore,
    receipt: restoreData.receipt,
  };
  return productIdFromRestore ? itemInRestore : false;
}
