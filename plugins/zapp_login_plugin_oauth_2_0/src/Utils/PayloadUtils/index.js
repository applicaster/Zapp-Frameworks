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
