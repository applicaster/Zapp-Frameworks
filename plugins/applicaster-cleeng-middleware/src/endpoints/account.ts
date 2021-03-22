import qs from "qs";
import BaseExtend from "../extends/base";
import { ApiConfig, Request } from "../models/Config";
import {
  CreateAccountData,
  ExtendTokenData,
  PurchaseItemData,
  PurchaseItemWithCouponData,
  ResetPasswordData,
  RestoreData,
  SignInData,
  SubscriptionsData,
} from "../models/Account";
import { API } from "../constants";
import { Account as AccountType } from "../models/Account";
import { AxiosResponse } from "axios";

class Account extends BaseExtend implements AccountType {
  constructor(config: ApiConfig, request: Request) {
    super(config, request);
  }
  createAccount(data: CreateAccountData): Promise<AxiosResponse<any>> {
    throw new Error("Method not implemented.");
  }
  resetPassword(data: ResetPasswordData): Promise<AxiosResponse<any>> {
    throw new Error("Method not implemented.");
  }
  extendToken(data: ExtendTokenData): Promise<AxiosResponse<any>> {
    throw new Error("Method not implemented.");
  }
  getAllSubscriptions(data: SubscriptionsData): Promise<AxiosResponse<any>> {
    throw new Error("Method not implemented.");
  }
  purchaseItem(data: PurchaseItemData): Promise<AxiosResponse<any>> {
    throw new Error("Method not implemented.");
  }
  purchaseItemWithCoupon(
    data: PurchaseItemWithCouponData
  ): Promise<AxiosResponse<any>> {
    throw new Error("Method not implemented.");
  }
  restore(data: RestoreData): Promise<AxiosResponse<any>> {
    throw new Error("Method not implemented.");
  }

  /** Returns the OAuth token
   *  @method getToken
   *  @example
   *  Cleeng.Account.getToken()
   *  @return {Credentials}
   */
  getToken = this.request.getToken;

  /** Returns a boolean if the user is authenticated
   *  @method isAuthenticated
   *  @example
   *  Cleeng.Account.isAuthenticated()
   *  @return {boolean}
   */
  isAuthenticated = this.request.isAuthenticated;

  /** Sets the Token
   *  @method setToken
   *  @param {string} token
   *  @param {string} refreshToken
   *  @param {number} expiresAt
   *  @example
   *  Cleeng.Account.setToken('344244-242242', '123123121-d1-t1-1ff',1558529593297)
   */
  setToken = this.request.setToken;

  /** Removes the token
   *  @method removeToken
   *  @example
   *  Cleeng.Account.removeToken()
   */
  removeToken = this.request.removeToken;

  /**
   * Signs in the user
   * @method signIn
   * @async
   * @typedef {Object} AxiosResponse<CreateAccount>
   * @param {AuthenticateData} data - Contains {
   *  email: string,
   *  password: string,
   * }
   * @example
   *     Cleeng.Account.signIn({
   *      email: 'test@test.com',
   *      password: 'test123',
   *     })
   *     .then(data => console.log(data));
   * @returns  {AxiosResponse<CreateAccount>}
   */
  async signIn(data: SignInData) {
    const body: any = {
      email: data.email,
      password: data.password,
    };

    body.publisherId = this.config.CLEENG_PUBLISHER_ID;

    const responseData = await this.request.post(
      API.signIn,
      qs.stringify(body),
      {
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
      }
    );

    console.log({ responseData });
    // await this.request.setToken(
    //   respData.data.access_token,
    //   respData.data.refresh_token,
    //   respData.data.expires
    // );

    return responseData;
  }
}

export default Account;
