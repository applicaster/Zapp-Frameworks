import { XRayLogLevel } from "./logLevels";

import { NativeModules } from "react-native";
import { logInConsole } from "./console";
import { logInXray } from "./xray";

const {
  XRayLoggerBridge,
}: { XRayLoggerBridge?: XRayLoggerNativeBridgeI } = NativeModules;

const XRayLoggerEnabled = !!XRayLoggerBridge;

if (!XRayLoggerEnabled) {
  logInConsole(XRayLogLevel.info, {
    category: "XRayLogger",
    subsystem: "XRayLogger/init",
    message:
      "XRayLogger native module not found. Logs will be directed to the console",
  });
}

const logFunction = XRayLoggerEnabled
  ? logInXray(XRayLoggerBridge)
  : logInConsole;

export function log(event: XRayEvent) {
  logFunction(XRayLogLevel.verbose, event);
}

export function debug(event: XRayEvent) {
  logFunction(XRayLogLevel.debug, event);
}

export function info(event: XRayEvent) {
  logFunction(XRayLogLevel.info, event);
}

export function warn(event: XRayEvent) {
  logFunction(XRayLogLevel.warning, event);
}

export function error(event: XRayEvent) {
  logFunction(XRayLogLevel.error, event);
}
