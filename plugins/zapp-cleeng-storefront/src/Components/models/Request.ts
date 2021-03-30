import { AxiosResponse } from "axios";

export interface SubscriptionsData {
  token: string;
  byAuthId: string;
  offers: string;
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

export interface Account {
  getAllSubscriptions(data: SubscriptionsData): Promise<AxiosResponse>;
  purchaseItem(data: PurchaseItemData): Promise<AxiosResponse>;
  purchaseItemWithCoupon(
    data: PurchaseItemWithCouponData
  ): Promise<AxiosResponse>;
  restore(data: RestoreData): Promise<AxiosResponse>;
}
