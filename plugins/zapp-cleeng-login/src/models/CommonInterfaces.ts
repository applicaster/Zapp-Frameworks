import { ApiConfig, Request } from "./Config";

export interface BaseExtend {
  config: ApiConfig;
  request: Request;
  setConfig: (publisherId: String) => void;
}

export interface CommonResponse {
  code: number;
  message: string;
}

export interface AdvanceError extends CommonResponse {
  errors?: Record<string, string>;
}

export interface CustomErrorResponse {
  status: number;
  data: CommonResponse;
}

export interface CredentialsConfig {
  token: string;
  refreshToken: string;
  expires: number;
}

export interface Credentials {
  token: string;
  refreshToken: string;
  expires: string;
  isExpired(): boolean;
  toObject(): CredentialsConfig;
}
