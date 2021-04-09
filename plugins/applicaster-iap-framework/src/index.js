import { NativeModules } from "react-native";
export { ApplicasterIAPModuleStubs } from "./Testing/ApplicasterIAPModuleStubs";

// eslint-disable-next-line prefer-promise-reject-errors
const nullPromise = () => Promise.reject("ApplicasterIAP bridge is null");
const defaultIAP = {
  signUp: nullPromise,
};

const { ApplicasterIAPBridge = defaultIAP } = NativeModules;

export const ApplicasterIAPModule = {
  async isInitialized() {
    return ApplicasterIAPBridge?.isInitialized?.();
  },

  /**
   * Initialize bridge with given billing provider on Android platform
   * @param {String} vendor: one of 'google_play' of 'amazon'
   */
  async initialize(vendor) {
    return ApplicasterIAPBridge?.initialize?.(vendor);
  },

  /**
   * Retrieve product for payload
   * @param {Array} payload Array of products data
   */
  async products(payload) {
    try {
      return ApplicasterIAPBridge.products(payload);
    } catch (e) {
      throw e;
    }
  },

  /**
   * Purchase item
   * @param {Object} payload Dictionary with user data
   */
  async purchase(payload) {
    try {
      return ApplicasterIAPBridge.purchase(payload);
    } catch (e) {
      throw e;
    }
  },
  /**
   * Restore Purchases
   */
  async restore() {
    try {
      return ApplicasterIAPBridge.restore();
    } catch (e) {
      throw e;
    }
  },
  /**
   * Finish purchased transaction
   * @param {Object} payload Dictionary transaction to finalize
   */
  async finishPurchasedTransaction(payload) {
    try {
      return ApplicasterIAPBridge.finishPurchasedTransaction(payload);
    } catch (e) {
      throw e;
    }
  },
};
