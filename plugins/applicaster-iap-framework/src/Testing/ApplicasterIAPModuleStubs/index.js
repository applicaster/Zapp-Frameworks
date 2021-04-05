import {
  productMockResponse,
  purchaseMock,
  restoreProductsMock,
} from "../Mocks";
export const ApplicasterIAPModuleStubs = {
  async isInitialized() {
    return true;
  },

  async initialize(vendor) {
    return true;
  },
  async products(payload) {
    console.log("products", productMockResponse);
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
    return restoreProductsMock;
  },

  async finishPurchasedTransaction(payload) {
    return true;
  },
};
