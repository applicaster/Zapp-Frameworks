import { Platform } from "react-native";
import { ApplicasterIAPModule } from "@applicaster/applicaster-iap";
import { validateExternalPayment } from "./inPlayerService";
import { findAsync } from "./InPlayerUtils";
import * as R from "ramda";
import MESSAGES from "../Components/AssetFlow/Config";
import {
  createLogger,
  BaseSubsystem,
  BaseCategories,
  XRayLogLevel,
} from "../Services/LoggerService";

export const logger = createLogger({
  subsystem: `${BaseSubsystem}/${BaseCategories.IAP_SERVICE}`,
  category: BaseCategories.IAP_SERVICE,
});

const isAndroid = Platform.OS === "android";

export async function initialize(store) {
  if (!isAndroid) {
    return true;
  }

  if (!store) {
    throw new Error(
      `Failed to initialize In App purchases plugin. Couldn't find the store data`
    );
  }

  const isInitialized = await ApplicasterIAPModule.isInitialized();
  if (isInitialized) {
    return true;
  }

  const initializationResult = await ApplicasterIAPModule.initialize(store);

  if (!initializationResult) {
    throw new Error(
      `Failed to initialize In App purchases plugin, ${initializationResult}`
    );
  }

  logger
    .createEvent()
    .setLevel(XRayLogLevel.debug)
    .addData({
      initializationResult,
      store,
    })
    .setMessage(
      `In App purchases service initialized:${initializationResult} store:${store}`
    )
    .send();

  return true;
}

export async function purchaseAnItem({
  purchaseID,
  item_id,
  access_fee_id,
  productType,
  store,
}) {
  if (!purchaseID) throw new Error(MESSAGES.validation.productId);
  let currentMessage = `ApplicasterIAPModule.purchase >> Purchasing purchase_id: ${purchaseID}`;
  let currentLogData = {};
  try {
    currentLogData = {
      purchase_id: purchaseID,
      item_id,
      access_fee_id,
      product_type: productType,
      store,
    };
    logger
      .createEvent()
      .setLevel(XRayLogLevel.debug)
      .addData(currentLogData)
      .setMessage(currentMessage)
      .send();

    const purchaseCompletion = await ApplicasterIAPModule.purchase({
      productIdentifier: purchaseID,
      finishing: false,
      productType,
    });

    logger
      .createEvent()
      .setLevel(XRayLogLevel.debug)
      .addData({
        purchase_id: purchaseID,
        item_id,
        access_fee_id,
        product_type: productType,
        store,
        purchase_completion: purchaseCompletion,
      })
      .setMessage(
        `ApplicasterIAPModule.purchase >> Purchase Completed purchase_id:${purchaseID}`
      )
      .send();

    const result = await externalPaymentValidation({
      purchaseCompletion,
      item_id,
      access_fee_id,
      store,
    });

    currentMessage = `ApplicasterIAPModule.finishPurchasedTransaction >> Finilizing transaction purchase_id:${purchaseID}`;
    currentLogData = {
      purchase_completion: purchaseCompletion,
      purchase_id: purchaseID,
      item_id,
      access_fee_id,
      product_type: productType,
      store,
    };
    logger
      .createEvent()
      .setLevel(XRayLogLevel.debug)
      .addData(currentLogData)
      .setMessage(currentMessage)
      .send();

    //TODO: When InPlayer will implement validation external transaction, should be called exectly when validation will send completion
    await ApplicasterIAPModule.finishPurchasedTransaction({
      ...purchaseCompletion,
      productType,
    });

    logger
      .createEvent()
      .setLevel(XRayLogLevel.debug)
      .addData({
        purchase_completion: purchaseCompletion,
        purchase_id: purchaseID,
        item_id,
        access_fee_id,
        product_type: productType,
        store,
      })
      .setMessage(
        `ApplicasterIAPModule.finishPurchasedTransaction >> Finilizing transaction completed purchase_id:${purchaseID}`
      )
      .send();
    return result;
  } catch (error) {
    logger
      .createEvent()
      .setLevel(XRayLogLevel.error)
      .addData({
        ...currentLogData,
        error,
      })
      .attachError(error)
      .setMessage(`${currentMessage} >> error message:${error.message}`)
      .send();
    throw error;
  }
}

export async function retrieveProducts(purchasableItems) {
  if (purchasableItems) {
    let mappedPurchasableItems = null;

    try {
      mappedPurchasableItems = R.map((item) => {
        const { externalFeeId } = item;
        if (externalFeeId) {
          return {
            ...item,
            productIdentifier: externalFeeId,
          };
        }

        return item;
      })(purchasableItems);

      logger
        .createEvent()
        .setLevel(XRayLogLevel.debug)
        .addData({
          purchasable_items: purchasableItems,
          mapped_purchasable_items: mappedPurchasableItems,
        })
        .setMessage(
          `ApplicasterIAPModule.products >> Retrive purchasable items`
        )
        .send();
      let result = await ApplicasterIAPModule.products(mappedPurchasableItems);
      result = R.prop("products")(result);

      logger
        .createEvent()
        .setLevel(XRayLogLevel.debug)
        .addData({
          purchasable_items: purchasableItems,
          mapped_purchasable_items: mappedPurchasableItems,
          retreived_products: Object.create(result),
        })
        .setMessage(
          `ApplicasterIAPModule.products >> Availible products to purchase recieved`
        )
        .send();

      return result;
    } catch (error) {
      logger
        .createEvent()
        .setLevel(XRayLogLevel.error)
        .addData({
          purchasable_items: purchasableItems,
          mapped_purchasable_items: mappedPurchasableItems,
          error,
        })
        .attachError(error)
        .setMessage(
          `ApplicasterIAPModule.products >> error message: ${error.message}`
        )
        .send();
      throw error;
    }
  } else {
    throw new Error(MESSAGES.validation.productId);
  }
}

async function externalPaymentValidation({
  purchaseCompletion,
  item_id,
  access_fee_id,
  store,
}) {
  let currentLogMessage = "";
  let currentLogData = {};
  try {
    const transactionIdentifier = purchaseCompletion?.transactionIdentifier;
    const productIdentifier = purchaseCompletion?.productIdentifier;
    const receipt = purchaseCompletion?.receipt;

    // Currently only avail for amazon, rest platform currently does not support this key
    const userId = purchaseCompletion?.userId;

    currentLogMessage = `Validating external payment - productIdentifier:${productIdentifier}, transactionIdentifier:${transactionIdentifier}`;
    currentLogData = {
      purchaseCompletion,
      item_id,
      access_fee_id,
      store,
      transaction_identifier: transactionIdentifier,
      product_identifier: productIdentifier,
      receipt,
      userId,
    };
    logger
      .createEvent()
      .setLevel(XRayLogLevel.debug)
      .addData(currentLogData)
      .setMessage(currentLogMessage)
      .send();

    const result = await validateExternalPayment({
      receipt,
      userId,
      item_id,
      access_fee_id,
      store,
    });

    logger
      .createEvent()
      .setLevel(XRayLogLevel.debug)
      .addData({
        purchaseCompletion,
        item_id,
        access_fee_id,
        store,
        transaction_identifier: transactionIdentifier,
        product_identifier: productIdentifier,
        receipt,
        userId,
        varification_result: result,
      })
      .setMessage(
        `Validate finished of external payment - productIdentifier:${productIdentifier}, transactionIdentifier:${transactionIdentifier}`
      )
      .send();

    return { transactionIdentifier, productIdentifier };
  } catch (error) {
    logger
      .createEvent()
      .setLevel(XRayLogLevel.error)
      .addData({
        ...currentLogData,
        error: error,
      })
      .attachError(error)
      .setMessage(`${currentLogMessage}, error message:${error.message}`)
      .send();
    throw error;
  }
}

async function findItemInRestoreAndroid(
  purchaseIdInPlayer,
  restoreResultFromStore
) {
  if (R.isEmpty(restoreResultFromStore)) return false;

  const itemFromRestore = await findAsync(
    restoreResultFromStore,
    async ({ productIdentifier }) => {
      return productIdentifier === purchaseIdInPlayer;
    }
  );
  return itemFromRestore?.receipt ? itemFromRestore : false;
}

async function findItemInRestoreIos(
  purchaseIdInPlayer,
  restoreResultFromStore
) {
  const restoredProductsIdArr = restoreResultFromStore?.restoredProducts;
  if (R.isEmpty(restoredProductsIdArr)) return false;

  const productIdFromRestore = await findAsync(
    restoredProductsIdArr,
    async (productIdentifier) => {
      return productIdentifier === purchaseIdInPlayer;
    }
  );

  const itemInRestore = {
    productIdentifier: productIdFromRestore,
    receipt: restoreResultFromStore.receipt,
  };
  return productIdFromRestore ? itemInRestore : false;
}

async function restoreAnItem(
  purchaseID,
  inPlayerProductId,
  restoreResultFromStore
) {
  const purchaseIdStr = purchaseID.toString();

  logger
    .createEvent()
    .setLevel(XRayLogLevel.debug)
    .addData({
      purchase_id: purchaseID,
      in_player_product_id: inPlayerProductId,
      restore_result_from_store: restoreResultFromStore,
      purchase_id_str: purchaseIdStr,
    })
    .setMessage(
      `Restore item - purchase_id:${purchaseID}, in_player_product_id:${inPlayerProductId}, purchase_id_str:${purchaseIdStr}`
    )
    .send();

  const itemFromStoreResult = isAndroid
    ? await findItemInRestoreAndroid(purchaseIdStr, restoreResultFromStore)
    : await findItemInRestoreIos(purchaseIdStr, restoreResultFromStore);

  if (!itemFromStoreResult) return false;

  const [item_id, access_fee_id] = inPlayerProductId.split("_");
  try {
    const result = await externalPaymentValidation({
      purchaseCompletion: itemFromStoreResult,
      item_id,
      access_fee_id,
    });

    logger
      .createEvent()
      .setLevel(XRayLogLevel.debug)
      .addData({
        purchase_id: purchaseID,
        in_player_product_id: inPlayerProductId,
        restore_result_from_store: restoreResultFromStore,
        purchase_id_str: purchaseIdStr,
      })
      .setMessage(
        `Restore item - completed, purchase_id:${purchaseID}, in_player_product_id:${inPlayerProductId}, purchase_id_str:${purchaseIdStr}`
      )
      .send();

    return result;
  } catch (error) {
    logger
      .createEvent()
      .setLevel(XRayLogLevel.error)
      .addData({
        purchase_id: purchaseID,
        in_player_product_id: inPlayerProductId,
        restore_result_from_store: restoreResultFromStore,
        purchase_id_str: purchaseIdStr,
        error,
      })
      .attachError(error)
      .setMessage(
        `Restore item - purchase_id:${purchaseID}, in_player_product_id:${inPlayerProductId}, purchase_id_str:${purchaseIdStr} >> error message:${error.message}`
      )
      .send();
    return {
      code: error?.response?.status,
      success: false,
      message: MESSAGES.restore.failInfo,
    };
  }
}

export async function restore(dataFromInPlayer) {
  try {
    logger
      .createEvent()
      .setLevel(XRayLogLevel.debug)
      .addData({
        data_from_in_player: dataFromInPlayer,
      })
      .setMessage(`ApplicasterIAPModule.restore >> Restore purched items`)
      .send();

    const restoreResultFromStore = await ApplicasterIAPModule.restore();

    const promises = dataFromInPlayer.map(
      async ({ productIdentifier, inPlayerProductId }) =>
        await restoreAnItem(
          productIdentifier,
          inPlayerProductId,
          restoreResultFromStore
        )
    );

    const restoreCompletionsArr = await Promise.all(promises);

    const restoreProcessedArr = restoreCompletionsArr.filter(Boolean);

    const isRestoreFailed = R.isEmpty(restoreProcessedArr);
    const isErrorOnAllRestores = restoreProcessedArr.every(
      ({ success }) => success === false
    );

    if (isRestoreFailed) throw new Error(MESSAGES.restore.empty);
    if (isErrorOnAllRestores) throw new Error(restoreProcessedArr[0].message);

    logger
      .createEvent()
      .setLevel(XRayLogLevel.debug)
      .addData({
        data_from_in_player: dataFromInPlayer,
      })
      .setMessage(`ApplicasterIAPModule.restore >> Restore complete`)
      .send();
  } catch (error) {
    logger
      .createEvent()
      .setLevel(XRayLogLevel.error)
      .addData({
        data_from_in_player: dataFromInPlayer,
        error,
      })
      .attachError(error)
      .setMessage(
        `ApplicasterIAPModule.restore >> Restore purched items >> error message:${error.message}`
      )
      .send();
  }
}
