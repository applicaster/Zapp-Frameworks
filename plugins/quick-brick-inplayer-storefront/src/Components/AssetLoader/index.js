import { createLogger, Subsystems } from "../../Services/LoggerService";
import {
  checkAccessForAsset,
  getAccessFees,
} from "../../Services/inPlayerService";
import { isWebBasedPlatform } from "../../Utils/Platform";
import MESSAGES from "../Config";
import {
  prepareInAppPurchaseData,
  retrieveInPlayerFeesData,
  isRequirePurchaseError,
} from "./Helper";

export const logger = createLogger({
  subsystem: Subsystems.ASSET_LOADER,
});

export async function assetLoaderStandaloneScreen({ props, assetId, store }) {
  try {
    const accessForAsset = await checkAccessForAsset({
      assetId,
    });
    const newPayload = await preparePayloadWithPurchaseData({
      props,
      assetId,
      store,
      accessForAsset,
    });

    return newPayload;
  } catch (error) {
    if (isWebBasedPlatform) {
      throw Error("Not supported web platform");
    } else if (error?.requestedToPurchase) {
      return await preparePayloadWithPurchaseData({ props, assetId, store });
    } else {
      handleError(error);
    }
  }
}
export async function assetLoader({
  props,
  assetId,
  store,
  retryInCaseFail = false,
}) {
  const payload = props?.payload;
  if (!assetId || !payload) {
    throw new Error(
      "AssetLoader: No Required Data, assetID or payload not exist"
    );
  }
  const { screenLocalizations } = props;

  try {
    const assetData = await checkAccessForAsset({
      assetId,
      retryInCaseFail,
    });
    const src = assetData?.src;
    const cookies = assetData?.cookies;
    if (assetData && src) {
      const newPayload = src && {
        ...payload,
        content: { src, cookies },
      };
      return newPayload;
    } else {
      throw Error(screenLocalizations.video_stream_exception_message);
    }
  } catch (error) {
    if (isWebBasedPlatform) {
      throw Error("Not supported web platform");
    } else if (error?.requestedToPurchase && retryInCaseFail === false) {
      return await preparePayloadWithPurchaseData({ props, assetId, store });
    } else {
      handleError(error);
    }
  }
}

async function preparePayloadWithPurchaseData({
  props,
  assetId,
  store,
  accessForAsset = null,
}) {
  const payload = props?.payload;

  const inPlayerFeesData = await preparePurchaseData({
    props,
    assetId,
    store,
  });
  if (inPlayerFeesData) {
    const newPayload = payload;
    newPayload.extensions.in_player_data = { inPlayerFeesData, assetId };
    newPayload.extensions.in_app_purchase_data = {
      productsToPurchase: prepareInAppPurchaseData(
        inPlayerFeesData,
        accessForAsset
      ),
    };

    return newPayload;
  }
  return null;
}

function handleError(error) {
  let status = error?.response?.status;
  if (status) {
    const statusString = status.toString();
    const message = isRequirePurchaseError(statusString)
      ? MESSAGES.purchase.required
      : statusString;
    const errorWithMessage = { ...error, message };
    throw errorWithMessage;
  } else {
    throw Error(MESSAGES.asset.fail);
  }
}

export async function preparePurchaseData({ props, assetId, store }) {
  const consumable_type_mapper = props?.configuration?.consumable_type_mapper;
  const non_consumable_type_mapper =
    props?.configuration?.non_consumable_type_mapper;
  const subscription_type_mapper =
    props?.configuration?.subscription_type_mapper;
  const in_player_environment = props?.configuration?.in_player_environment;

  try {
    const purchaseKeysMapping = {
      consumable_type_mapper,
      non_consumable_type_mapper,
      subscription_type_mapper,
    };

    const accessFees = await getAccessFees(assetId);

    const inPlayerFeesData = retrieveInPlayerFeesData({
      feesToSearch: accessFees,
      purchaseKeysMapping,
      in_player_environment,
      store,
    });
    logger.debug({
      message: "preparePurchaseData: Purchase fee data",
      data: {
        access_fees: accessFees,
        in_player_fees_data: inPlayerFeesData,
        purchase_keysMapping: purchaseKeysMapping,
      },
    });

    return inPlayerFeesData;
  } catch (error) {
    logger.error({
      message: "preparePurchaseData: Purchase fee data Failed",
      data: {
        error,
      },
    });
    throw error;
  }
}
