import {
  productMockResponse,
  purchaseMock,
  restoreProductsMockiOS,
  restoreProductsMockAndroid,
} from "../Mocks";
import { Platform } from "react-native";
export const isApplePlatform = Platform.OS === "ios";

export const ApplicasterIAPModuleStubs = {
  async isInitialized() {
    return true;
  },

  async initialize(vendor) {
    return true;
  },
  async products(payload) {
    return { ...productMockResponse, payload };
  },

  async purchase(payload) {
    return {
      ...purchaseMock,
      payload,
      productIdentifier: payload?.productIdentifier,
    };
  },

  async restore() {
    return isApplePlatform
      ? restoreProductsMockiOS
      : restoreProductsMockAndroid;
  },

  async finishPurchasedTransaction(payload) {
    return true;
  },
};
