import { AxiosResponse } from "axios";

export interface SubscriptionsData {
  token: string;
  publisherId: string;
  offers: Array<string>;
}

export interface RecieptInfo {
  transactionId: string;
  receiptData: string; // Base 64 encoded
}

export interface PurchaseItemData {
  receipt: RecieptInfo;
  offerId: string;
  token: string;
  isRestored: boolean;
  publisherId: string;
}

export interface PurchaseItemWithCouponData {
  appType: string;
  offerId: string;
  token: string;
  couponCode: string;
}

export interface RestoreProduct {
  productIdentifier: string;
  transactionIdentifier: string;
}
export interface RestoreData {
  restoreData: {receipt:string, products:Array<RestoreProduct>};
  offers: Array<string>;
  token: string;
  publisherId: string;
}

export interface RequestCustomData {
  base_URL_api: string;
  get_items_to_purchase_api_endpoint: string;
  purchase_an_item: string;
  restore_api_endpoint: string;
}

export interface ExtendTokenData {
  token: string;
  publisherId: string;
}
