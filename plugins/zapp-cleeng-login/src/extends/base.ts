import { ApiConfig, Request } from "../models/Config";
import configOptions from "../config";

class BaseExtend {
  config: ApiConfig;
  request: Request;
  constructor(config: ApiConfig, request: Request) {
    this.config = config;
    this.request = request;
  }

  setConfig = (publisherId: string) => {
    this.config = configOptions;
    this.config.CLEENG_PUBLISHER_ID = publisherId;
  };
}

export default BaseExtend;
