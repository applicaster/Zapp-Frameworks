// @flow
import { NativeModules } from "react-native";

const { XRayLoggerBridge } = NativeModules;

export const Logger = {
  /**
   * Log debug event
   * @param {String} category
   * @param {String} subsystem
   * @param {String} message
   * @return {*}
   */
  d(category, subsystem, message) {
    XRayLoggerBridge.logEvent({
      category,
      subsystem,
      level: 3,
      message,
    });
  },
  /**
   * Log error event
   * @param {String} category
   * @param {String} subsystem
   * @param {String} message
   * @return {*}
   */
  e(category, subsystem, message) {
    XRayLoggerBridge.logEvent({
      category,
      subsystem,
      level: 6,
      message,
    });
  },
};
