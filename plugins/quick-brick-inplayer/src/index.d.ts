declare type PluginConfiguration = {
  in_player_custom_asset_key: string;
};

declare type ExternalAssetData = {
  externalAssetId: string | number;
  inplayerAssetType: string;
};

declare type AssetForAssetParams = {
  assetId: number;
  retryInCaseFail: boolean;
  interval?: number;
  tries?: number;
};

declare type LoginParams = {
  email: string;
  password: string;
  clientId: string;
  referrer: string;
};

declare type SignUpParams = {
  fullName: string;
  email: string;
  password: string;
  clientId: string;
  referrer: string;
  brandingId: number;
};

declare type RequestNewPasswordParams = {
  email: string;
  clientId: string;
  brandingId: number;
};

declare type SetNewPasswordParams = {
  password: string;
  token: string;
  brandingId: number;
};

declare type ValidateExternalPaymentParams = {
  receipt: string;
  userId: string;
  item_id: number;
  access_fee_id: number;
  store: string;
};
