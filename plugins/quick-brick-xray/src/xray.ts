import { logInConsole } from "./console";
import { XRayLogLevel } from "./logLevels";

import { sanitizeEventPayload } from "./utils";

export function logInXray(XRayLoggerBridge: XRayLoggerNativeBridgeI) {
  return function (level: XRayLogLevel, event: XRayEvent): void {
    if (__DEV__) {
      // When running RN in dev mode, we want to log in the console anyway
      logInConsole(level, event);
    }

    if (event.jsOnly) return;

    try {
      delete event.jsOnly;
      XRayLoggerBridge.logEvent({ level, ...sanitizeEventPayload(event) });
    } catch (e) {
      // eslint-disable-next-line no-console
      console.warn("An error occurred when trying to log an XRay event", {
        e,
        event,
      });
    }
  };
}
