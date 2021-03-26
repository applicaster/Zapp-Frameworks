import axios, { AxiosInstance, AxiosRequestConfig } from "axios";
import Credentials from "./credentials";
import { CustomErrorResponse } from "../models/CommonInterfaces";
import { ApiConfig } from "../models/Config";
import configOptions from "../config";
import tokenStorage from "./tokenStorage";
import { isPromise, createCredentials } from "../helpers";

// Make maybe to get headers as params
const getHeaders = () => ({
  headers: {
    Accept: "application/json",
    "Content-Type": "application/json",
  },
});

export default class Request {
  config: ApiConfig;
  basicInstance: AxiosInstance;
  authenticatedInstance: AxiosInstance;

  constructor(config: ApiConfig) {
    this.config = config;
    this.basicInstance = axios.create({
      baseURL: this.config.BASE_URL,
    });
    this.authenticatedInstance = axios.create({
      baseURL: this.config.BASE_URL,
    });
    this.authenticatedInstance.interceptors.request.use(
      this.createAuthInterceptor
    );
  }

  setInstanceConfig = () => {
    this.config = configOptions;
    this.basicInstance = axios.create({
      baseURL: this.config.BASE_URL,
    });
    this.authenticatedInstance = axios.create({
      baseURL: this.config.BASE_URL,
    });
    this.authenticatedInstance.interceptors.request.use(
      this.createAuthInterceptor
    );
  };

  /** Returns the OAuth token
   *  @method getToken
   *  @example
   *  Cleeng.Account.getToken()
   *  @return {Credentials}
   */
  getToken = () => {
    const tokenString = tokenStorage.getItem(this.config.TOKEN_KEY);

    if (isPromise(tokenString)) {
      return (tokenString as Promise<string>).then((resolvedString) =>
        createCredentials(resolvedString)
      );
    }
    return createCredentials(tokenString as string);
  };

  /** Sets the token
   *  @method setToken
   *  @param {string} token
   *  @param {string} refreshToken
   *  @param {number} expiresAt
   *  @example
   *  InPlayer.Account.setToken('344244-242242', '123123121-d1-t1-1ff',1558529593297)
   */
  setToken = (token: string, refreshToken: string, expiresAt: number) => {
    const credentials = new Credentials({
      token,
      refreshToken,
      expires: expiresAt,
    });

    return tokenStorage.setItem(
      this.config.TOKEN_KEY,
      JSON.stringify(credentials)
    );
  };

  /** Removes the token
   *  @method removeToken
   *  @example
   *  InPlayer.Account.removeToken()
   */
  removeToken = (): void | Promise<void> => {
    const tasks: Array<void | Promise<void>> = [
      tokenStorage.removeItem(this.config.TOKEN_KEY),
    ];

    if (!tasks.some(isPromise)) {
      return undefined;
    }

    return Promise.all(tasks).then(() => undefined);
  };

  /**
   * Checks if the user is authenticated
   * @method isAuthenticated
   * @example
   *    Cleeng.Account.isAuthenticated()
   * @return {Boolean}
   */
  isAuthenticated = () => {
    const tokenObject = this.getToken();

    if (isPromise(tokenObject)) {
      return (tokenObject as Promise<Credentials>).then(
        (resolvedCredentials) =>
          !resolvedCredentials.isExpired() && !!resolvedCredentials.token
      );
    }

    const credentials = tokenObject as Credentials;

    return !credentials.isExpired() && !!credentials.token;
  };

  // HTTP GET Request - Returns Resolved or Rejected Promise
  get = (
    path: string,
    headers?: Record<string, Record<string, unknown> | string | boolean>
  ) => this.basicInstance.get(path, headers || getHeaders());

  // HTTP PATCH Request - Returns Resolved or Rejected Promise
  patch = (
    path: string,
    data: any,
    headers?: Record<string, Record<string, unknown> | string | boolean>
  ) => this.basicInstance.patch(path, data, headers || getHeaders());

  // HTTP POST Request - Returns Resolved or Rejected Promise
  post = (
    path: string,
    data: any,
    headers?: Record<string, Record<string, unknown> | string | boolean>
  ) => this.basicInstance.post(path, data, headers || getHeaders());

  // HTTP PUT Request - Returns Resolved or Rejected Promise
  put = (
    path: string,
    data: any,
    headers?: Record<string, Record<string, unknown> | string | boolean>
  ) => this.basicInstance.put(path, data, headers || getHeaders());

  // HTTP DELETE Request - Returns Resolved or Rejected Promise
  delete = (
    path: string,
    headers?: Record<string, Record<string, unknown> | string | boolean>
  ) => this.basicInstance.delete(path, headers || getHeaders());

  // HTTP GET Request - Returns Resolved or Rejected Promise
  authenticatedGet = (
    path: string,
    headers?: Record<string, Record<string, unknown> | string | boolean>
  ) => this.authenticatedInstance.get(path, headers || getHeaders());

  // HTTP PATCH Request - Returns Resolved or Rejected Promise
  authenticatedPatch = (
    path: string,
    data: any,
    headers?: Record<string, Record<string, unknown> | string | boolean>
  ) => this.authenticatedInstance.patch(path, data, headers || getHeaders());

  // HTTP POST Request - Returns Resolved or Rejected Promise
  authenticatedPost = (
    path: string,
    data: any,
    headers?: Record<string, Record<string, unknown> | string | boolean>
  ) => this.authenticatedInstance.post(path, data, headers || getHeaders());

  // HTTP PUT Request - Returns Resolved or Rejected Promise
  authenticatedPut = (
    path: string,
    data: any,
    headers?: Record<string, Record<string, unknown> | string | boolean>
  ) => this.authenticatedInstance.put(path, data, headers || getHeaders());

  // HTTP DELETE Request - Returns Resolved or Rejected Promise
  authenticatedDelete = (
    path: string,
    headers?: Record<string, Record<string, unknown> | string | boolean>
  ) => this.authenticatedInstance.delete(path, headers || getHeaders());

  createAuthInterceptor = (axiosConfig: AxiosRequestConfig) => {
    const auth = this.isAuthenticated();
    // Build and Record<string, unknown> similar to an Axios error response
    if (!auth) {
      const response: CustomErrorResponse = {
        status: 401,
        data: {
          code: 401,
          message: "The user is not authenticated.",
        },
      };
      throw { response };
    }
    return axiosConfig;
  };
}