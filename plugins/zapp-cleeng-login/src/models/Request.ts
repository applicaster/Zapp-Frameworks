import { AxiosResponse } from "axios";

export interface CreateAccountData {
  email: string;
  password: string;
  publisherId: string;
}

export interface SignInData {
  email: string;
  password: string;
  publisherId: string;
}

export interface ResetPasswordData {
  email: string;
  publisherId: string;
}

export interface ExtendTokenData {
  token: string;
}

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
  signIn(data: SignInData): Promise<AxiosResponse>;
  createAccount(data: CreateAccountData): Promise<AxiosResponse>;
  resetPassword(data: ResetPasswordData): Promise<AxiosResponse>;
  extendToken(data: ExtendTokenData): Promise<AxiosResponse>;
  getAllSubscriptions(data: SubscriptionsData): Promise<AxiosResponse>;
  purchaseItem(data: PurchaseItemData): Promise<AxiosResponse>;
  purchaseItemWithCoupon(
    data: PurchaseItemWithCouponData
  ): Promise<AxiosResponse>;
  restore(data: RestoreData): Promise<AxiosResponse>;
}
