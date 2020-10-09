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

function invokeLogger(level: XRayLogLevel, event: XRayEvent) {
  if (!event?.jsOnly && XRayLoggerEnabled) {
    return logInXray(XRayLoggerBridge)(level, event);
  }

  logInConsole(level, event);
}

export function log(event: XRayEvent) {
  invokeLogger(XRayLogLevel.verbose, event);
}

export function debug(event: XRayEvent) {
  invokeLogger(XRayLogLevel.debug, event);
}

export function info(event: XRayEvent) {
  invokeLogger(XRayLogLevel.info, event);
}

export function warn(event: XRayEvent) {
  invokeLogger(XRayLogLevel.warning, event);
}

export function error(event: XRayEvent) {
  invokeLogger(XRayLogLevel.error, event);
}
