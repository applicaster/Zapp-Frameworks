export interface OfferItem {
  accessGranted: boolean;
  accessToTags: Array<string>;
  active: boolean;
  androidProductId: string;
  appleProductId: string;
  applicableTaxRate: number;
  authId: string;
  averageRating: number;
  contentType?: string;
  country: string;
  createdAt: number;
  currency: string;
  description?: string;
  expiresAt?: number;
  freeDays: string;
  freePeriods: string;
  geoRestrictionCountries: Array<string>;
  geoRestrictionEnabled: boolean;
  geoRestrictionType?: string;
  id: string;
  is_voucher_promoted: boolean;
  period: string;
  price: number;
  publisherEmail: string;
  should_hide_free_ribbon: boolean;
  socialCommissionRate: number;
  title: string;
  updatedAt: number;
  url: string;
}

export interface TokenData {
  authId: string;
  offerId: string;
  token: string;
}
