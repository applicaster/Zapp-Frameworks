import { logInConsole } from "./console";
import { XRayLogLevel } from "./logLevels";

import { sanitizeEventData } from "./utils";

export function logInXray(XRayLoggerBridge: XRayLoggerNativeBridgeI) {
  return function (level: XRayLogLevel, event: XRayEvent): void {
    if (__DEV__) {
      // When running RN in dev mode, we want to log in the console anyway
      logInConsole(level, event);
    }

    XRayLoggerBridge.logEvent({ level, ...sanitizeEventData(event) });
  };
}
