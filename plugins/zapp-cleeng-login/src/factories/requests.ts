import axios from "axios";

const Request = {
  post: async (
    path: string,
    data: any,
    baseURL: string = "https://applicaster-cleeng-sso.herokuapp.com"
  ) => {
    const request: AxiosRequestConfig = {
      url: path,
      baseURL: baseURL,
      method: "POST",
      data,
    };
    console.log({ request });
    return await axios(request);
  },
};

export default Request;
