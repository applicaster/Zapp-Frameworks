import { CredentialsConfig } from "./CommonInterfaces";
export interface ApiConfig {
  BASE_URL: string;
  CLEENG_PUBLISHER_ID: string;
  TOKEN_KEY: string;
}

export interface ApiEndpoints {
  signIn: string;
  signOut: string;
  signUp: string;
  passwordReset: string;
  extendToken: string;
  subscriptions: string;
  purchaseItem: string;
  restore: string;
}

export interface Request {
  getToken(): CredentialsConfig | Promise<CredentialsConfig>;
  setToken(
    token: string,
    refreshToken: string,
    expiresAt: number
  ): void | Promise<void>;
  removeToken(): void | Promise<void>;
  isAuthenticated(): boolean | Promise<boolean>;
  get(
    path: string,
    headers?: Record<string, Record<string, unknown> | string | boolean>
  ): any;
  post(
    path: string,
    data: any,
    headers?: Record<string, Record<string, unknown> | string | boolean>
  ): any;
  put(
    path: string,
    data: any,
    headers?: Record<string, Record<string, unknown> | string | boolean>
  ): any;
  patch(
    path: string,
    data: any,
    headers?: Record<string, Record<string, unknown> | string | boolean>
  ): any;
  delete(
    path: string,
    headers?: Record<
      string,
      Record<string, unknown> | FormData | string | boolean
    >
  ): any;
  authenticatedGet(
    path: string,
    headers?: Record<string, Record<string, unknown> | string | boolean>
  ): any;
  authenticatedPatch(
    path: string,
    data: any,
    headers?: Record<string, Record<string, unknown> | string | boolean>
  ): any;
  authenticatedPost(
    path: string,
    data: any,
    headers?: Record<string, Record<string, unknown> | string | boolean>
  ): any;
  authenticatedPut(
    path: string,
    data: any,
    headers?: Record<string, Record<string, unknown> | string | boolean>
  ): any;
  authenticatedDelete(
    path: string,
    headers?: Record<string, Record<string, unknown> | string | boolean>
  ): any;
  setInstanceConfig(publisherId: string): void;
}
