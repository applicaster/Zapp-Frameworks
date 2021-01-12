import * as R from "ramda";
import {
  createLogger,
  BaseSubsystem,
  BaseCategories,
  XRayLogLevel
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
    logger
      .createEvent()
      .setLevel(XRayLogLevel.debug)
      .addData({
        external_asset_id: externalAssetId,
        inplayer_asset_type: inplayerAssetType,
      })
      .setMessage(
        `${eventMessage} external_asset_id: ${externalAssetId}, inplayer_asset_type: ${inplayerAssetType} from payload`
      )
      .send();

    return { externalAssetId, inplayerAssetType };
  }

  logger
    .createEvent()
    .setLevel(XRayLogLevel.debug)
    .addData({
      external_asset_id: externalAssetId,
      inplayer_asset_type: inplayerAssetType,
    })
    .setMessage(`${eventMessage} data not availible`)
    .send();
  return null;
};

export const isAuthenticationRequired = ({ payload }) => {
  const requires_authentication = R.path([
    "extensions",
    "requires_authentication",
  ])(payload);
  logger
    .createEvent()
    .setLevel(XRayLogLevel.debug)
    .addData({
      requires_authentication: requires_authentication,
    })
    .setMessage(
      `Payload entry is requires_authentication: ${requires_authentication}`
    )
    .send();
  return requires_authentication;
};

export const inPlayerAssetId = ({ payload, configuration }) => {
  let eventMessage = "inplayer_asset_id from payload:";
  const event = logger.createEvent().setLevel(XRayLogLevel.debug);

  const assetIdFromCustomKey = inPlayerAssetIdFromCustomKey({
    payload,
    configuration,
  });

  if (assetIdFromCustomKey) {
    event
      .addData({ inplayer_asset_id: assetIdFromCustomKey })
      .setMessage(
        `${eventMessage} from in_player_custom_asset_key, inplayer_asset_id: ${assetIdFromCustomKey}`
      )
      .send();
    return assetIdFromCustomKey;
  }

  const assetId = R.path(["extensions", "inplayer_asset_id"])(payload);
  if (assetId) {
    event
      .addData({ inplayer_asset_id: assetId })
      .setMessage(
        `${eventMessage} from extensions.inplayer_asset_id, inplayer_asset_id: ${assetId}`
      )
      .send();
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

  event
    .addData({ inplayer_asset_id: assetIdFallback })
    .setMessage(eventMessage)
    .send();

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

export const isVideoEntry = (payload) => {
  const retVal = R.compose(
    R.equals("video"),
    R.path(["type", "value"])
  )(payload);

  logger
    .createEvent()
    .setLevel(XRayLogLevel.debug)
    .addData({
      is_video_entry: retVal,
    })
    .setMessage(`Payload entry is_video_entry: ${retVal}`)
    .send();

  return retVal;
};

export const assetPaymentRequired = R.compose(
  R.equals(402),
  R.path(["response", "status"])
);
