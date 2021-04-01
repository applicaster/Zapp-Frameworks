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
  receiptData: RecieptInfo;
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

export interface RestoreData {
  appType: string;
  receipts: { productId: string; transactionId: string }[];
  token: string;
  receiptData: RecieptInfo;
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
