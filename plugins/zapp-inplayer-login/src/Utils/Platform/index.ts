import { Platform } from "react-native";

export const isWebBasedPlatform = Platform.OS === "web";

export function isAmazonPlatform(store: string) {
  return store && store === "amazon";
}

export const isApplePlatform = Platform.OS === "ios";
export const isAndroidPlatform = Platform.OS === "android";
