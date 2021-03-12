import { Platform } from "react-native";
import { ApplicasterIAPModule } from "@applicaster/applicaster-iap";
import * as R from "ramda";
import MESSAGES from "../../Config";
import {
  createLogger,
  BaseSubsystem,
  BaseCategories,
} from "../../Services/LoggerService";

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
  logger.debug({
    message: `In App purchases service initialized:${initializationResult} store:${store}`,
    data: {
      initializationResult,
      store,
    },
  });

  return true;
}

export async function purchaseAnItem({ productIdentifier, productType }) {
  console.log({ productIdentifier, productType });
  if (!productIdentifier) throw new Error(MESSAGES.validation.productId);
  try {
    logger.debug({
      message: `purchaseAnItem: >> Purchasing productIdentifier: ${productIdentifier}`,
      data: {
        productIdentifier,
        productType,
      },
    });

    const purchaseCompletion = await ApplicasterIAPModule.purchase({
      productIdentifier,
      finishing: false,
      productType,
    });

    logger.debug({
      message: `purchaseAnItem: ApplicasterIAPModule.purchase >> Purchase Completed product_identifier:${productIdentifier}`,
      data: {
        productIdentifier,
        productType,
        purchase_completion: purchaseCompletion,
      },
    });

    const result = await ApplicasterIAPModule.finishPurchasedTransaction({
      ...purchaseCompletion,
      productType,
    });
    console.log({ result, purchaseCompletion });
    logger.debug({
      message: `purchaseAnItem: ApplicasterIAPModule.finishPurchasedTransaction >> Finilizing transaction completed product_identifier:${productIdentifier}`,
      data: {
        productIdentifier,
        productType,
        purchase_completion: purchaseCompletion,
      },
    });
    return purchaseCompletion;
  } catch (error) {
    logger.error({
      message: `purchaseAnItem: >> error message:${error.message}`,
      data: {
        productIdentifier,
        productType,
      },
    });

    throw error;
  }
}

export async function retrieveProducts(purchasableItems) {
  console.log({ purchasableItems });
  if (purchasableItems) {
    try {
      logger.debug({
        message: `retrieveProducts: ApplicasterIAPModule.products >> Retrive purchasable items`,
        data: {
          purchasable_items: purchasableItems,
        },
      });

      let result = await ApplicasterIAPModule.products(purchasableItems);
      console.log({ result });
      result = R.prop("products")(result);

      logger.debug({
        message: `retrieveProducts: ApplicasterIAPModule.products >> Availible products to purchase recieved`,
        data: {
          purchasable_items: purchasableItems,
          retreived_products: Object.create(result),
        },
      });

      return result;
    } catch (error) {
      logger.error({
        message: `retrieveProducts: ApplicasterIAPModule.products >> error message: ${error.message}`,
        data: {
          purchasable_items: purchasableItems,
          error,
        },
      });

      throw error;
    }
  } else {
    throw new Error(MESSAGES.validation.productId);
  }
}

export async function restore() {
  try {
    logger.debug({
      message: `ApplicasterIAPModule.restore >> Restore purched items`,
    });

    const restoreResultFromStore = await ApplicasterIAPModule.restore();
    console.log({ restoreResultFromStore });
    logger.debug({
      message: `ApplicasterIAPModule.restore >> Restore complete`,
      data: { restored_data: restoreResultFromStore },
    });
    return restoreResultFromStore;
  } catch (error) {
    logger.error({
      message: `ApplicasterIAPModule.restore >> Restore purched items >> error message:${error.message}`,
      data: {
        error,
      },
    });
  }
}
