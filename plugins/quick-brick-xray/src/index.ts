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

const XRayLogger: XRayLoggerI = {
  log(event) {
    logFunction(XRayLogLevel.verbose, event);
  },
  debug(event) {
    logFunction(XRayLogLevel.debug, event);
  },
  info(event) {
    logFunction(XRayLogLevel.info, event);
  },
  warning(event) {
    logFunction(XRayLogLevel.warning, event);
  },
  error(event) {
    logFunction(XRayLogLevel.error, event);
  },
};

export default XRayLogger;
