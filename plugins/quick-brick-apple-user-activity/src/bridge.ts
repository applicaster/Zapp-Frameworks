import { NativeModules } from "react-native";

interface NativeModulesI {
  AppleUserActivityBridge: AppleUserActivityBridgeI;
}

const {AppleUserActivityBridge} = NativeModules as NativeModulesI;

export function defineUserActivity(options) {
  AppleUserActivityBridge?.defineUserActivity?.(options);
};

export function removeUserActivity() {
  AppleUserActivityBridge?.removeUserActivity?.();
};