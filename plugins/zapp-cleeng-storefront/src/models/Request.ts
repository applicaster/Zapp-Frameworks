import { AxiosResponse } from "axios";

export interface SubscriptionsData {
  token: string;
  publisherId: string;
}

export interface RecieptInfo {
  transactionId: string;
  receiptData: string; // Base 64 encoded
}

export interface PurchaseItemData {
  appType: string; //ios/android
  receiptData: RecieptInfo;
  offerId: string;
  token: string;
  isRestored: string;
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
  login_api_endpoint: string;
  signin_api_endpoint: string;
  password_reset_api_endpoint: string;
}
