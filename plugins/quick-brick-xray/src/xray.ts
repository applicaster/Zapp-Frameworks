import { logInConsole } from "./console";

const XRayMethods = {
  [XRayLogLevel.verbose]: "l",
  [XRayLogLevel.debug]: "d",
  [XRayLogLevel.info]: "i",
  [XRayLogLevel.warning]: "w",
  [XRayLogLevel.error]: "e",
};

export function logInXray(XRayLoggerBridge: XRayLoggerNativeBridgeI) {
  return function (level: XRayLogLevel, event: XRayEvent): void {
    if (__DEV__) {
      // When running RN in dev mode, we want to log in the console anyway
      logInConsole(level, event);
    }

    XRayLoggerBridge[XRayMethods[level]]({ level, ...event });
  };
}
