import axios from "axios";
import { RequestCustomData } from "../models/Request";
import { API } from "../constants";

const Request = (function () {
  var customData: RequestCustomData;

  return {
    prepare: (data: RequestCustomData) => {
      customData = data;
    },
    post: async (path: string, data: any) => {
      if (!customData) {
        throw Error("No custom data provided to requests");
      }
      let newPath = path;

      // switch (newPath) {
      //   case API.signIn:
      //     newPath = customData.login_api_endpoint;
      //     break;
      //   case API.signUp:
      //     newPath = customData.login_api_endpoint;
      //     break;
      //   case API.passwordReset:
      //     newPath = customData.password_reset_api_endpoint;
      //     break;
      //   default:
      //     break;
      // }

      const request: AxiosRequestConfig = {
        url: newPath,
        baseURL: customData.base_URL_api,
        method: "POST",
        data,
      };

      return await axios(request);
    },
  };
})();
export default Request;
