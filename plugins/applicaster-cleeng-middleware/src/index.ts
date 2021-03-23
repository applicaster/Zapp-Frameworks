import Account from "./endpoints/account";
// import Payment from "./endpoints/payment";
import config from "./config";
import RequestFactory from "./factories/requests";

// types
import { ApiConfig, Request as RequestType } from "./models/Config";
import { Account as AccountType } from "./models/Account";

import tokenStorage, { TokenStorageType } from "./factories/tokenStorage";

/**
 * Main class. Contains all others methods and websocket subscription
 *
 * @class Cleeng
 */
class CleengMiddleware {
  config: ApiConfig;
  Account: AccountType;
  request: RequestType;
  tokenStorage: TokenStorageType = tokenStorage;

  constructor() {
    this.request = new RequestFactory(this.config);
    /**
     * @property Account
     * @type Account
     */
    this.Account = new Account(this.config, this.request);

    // /**
    //  * @property Payment
    //  * @type Payment
    //  */
    // this.Payment = new Payment(this.config, this.request);
  }

  /**
   * Overrides the default configs
   * @method setConfig
   * @param {String} config 'production', 'development'
   * @example
   *     InPlayer.setConfig('development');
   */
  setConfig(publisherId: string) {
    this.config = config;
    this.request.setInstanceConfig(publisherId);
    this.Account.setConfig(publisherId);

    // this.Payment.setConfig(env);
  }
}

export default new CleengMiddleware();
