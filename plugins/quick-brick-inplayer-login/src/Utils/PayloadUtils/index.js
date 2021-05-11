import * as R from "ramda";
import {
  createLogger,
  BaseSubsystem,
  BaseCategories,
  XRayLogLevel,
} from "../../Services/LoggerService";

export const logger = createLogger({
  subsystem: BaseSubsystem,
  category: BaseCategories.PAYLOAD_HELPER,
});

export const externalAssetData = ({ payload }) => {
  const { id: externalAssetId } = payload;
  const inplayerAssetType = R.path(["extensions", "inplayer_asset_type"])(
    payload
  );
  let eventMessage = "External Asset Data from Payload:";

  if (externalAssetId && inplayerAssetType) {
    logger.debug({
      message: `${eventMessage} external_asset_id: ${externalAssetId}, inplayer_asset_type: ${inplayerAssetType} from payload`,
      data: {
        external_asset_id: externalAssetId,
        inplayer_asset_type: inplayerAssetType,
      },
    });

    return { externalAssetId, inplayerAssetType };
  }

  logger.debug({
    message: `${eventMessage} data not availible`,
    data: {
      external_asset_id: externalAssetId,
      inplayer_asset_type: inplayerAssetType,
    },
  });

  return null;
};

export const isAuthenticationRequired = ({ payload }) => {
  const requires_authentication = R.path([
    "extensions",
    "requires_authentication",
  ])(payload);

  logger.debug({
    message: `Payload entry is requires_authentication: ${requires_authentication}`,
    data: {
      requires_authentication: requires_authentication,
    },
  });
  return requires_authentication || payload?.type;
};

export const inPlayerAssetId = ({ payload, configuration }) => {
  let eventMessage = "inplayer_asset_id from payload:";

  const assetIdFromCustomKey = inPlayerAssetIdFromCustomKey({
    payload,
    configuration,
  });

  if (assetIdFromCustomKey) {
    logger.debug({
      message: `${eventMessage} from in_player_custom_asset_key, inplayer_asset_id: ${assetIdFromCustomKey}`,
      data: {
        inplayer_asset_id: assetIdFromCustomKey,
      },
    });
    return assetIdFromCustomKey;
  }

  const assetId = R.path(["extensions", "inplayer_asset_id"])(payload);
  if (assetId) {
    logger.debug({
      message: `${eventMessage} from extensions.inplayer_asset_id, inplayer_asset_id: ${assetId}`,
      data: {
        inplayer_asset_id: assetId,
      },
    });
    return assetId;
  }

  // Legacy keys, should not be used if future.
  // Remove at once we will make sure that not needed
  const assetIdFallback = R.compose(
    R.ifElse(Array.isArray, R.head, R.always(null)),
    R.path(["extensions", "ds_product_ids"])
  )(payload);
  eventMessage = assetIdFallback
    ? `${eventMessage} from pathextensions.ds_product_ids, inplayer_asset_id: ${assetId}`
    : `${eventMessage} data not availible`;

  logger.debug({
    message: eventMessage,
    data: {
      inplayer_asset_id: assetIdFallback,
    },
  });

  return assetIdFallback;
};

const inPlayerAssetIdFromCustomKey = ({ payload, configuration }) => {
  const in_player_custom_asset_key = configuration?.in_player_custom_asset_key;
  if (in_player_custom_asset_key) {
    const devidedArray = R.split(".")(in_player_custom_asset_key);
    const assetId = R.path(devidedArray)(payload);
    return assetId;
  } else {
    return null;
  }
};

export const assetPaymentRequired = R.compose(
  R.equals(402),
  R.path(["response", "status"])
);
