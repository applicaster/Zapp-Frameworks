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
