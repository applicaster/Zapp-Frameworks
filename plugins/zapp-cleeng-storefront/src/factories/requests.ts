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
      console.log({ newPath, data, customData });
      // switch (newPath) {
      //   case API.subscriptions:
      //     newPath = customData.get_items_to_purchase_api_endpoint;
      //     break;
      //   case API.purchaseItem:
      //     newPath = customData.purchase_an_item;
      //     break;
      //   case API.restore:
      //     newPath = customData.restore_api_endpoint;
      //     break;
      //   default:
      //     break;
      // }

      //TODO: Fix newPath bug on cleeng login
      const request: AxiosRequestConfig = {
        url: newPath,
        baseURL: customData.base_URL_api,
        method: "POST",
        data,
      };
      console.log({ request });

      return await axios(request);
    },
  };
})();
export default Request;
