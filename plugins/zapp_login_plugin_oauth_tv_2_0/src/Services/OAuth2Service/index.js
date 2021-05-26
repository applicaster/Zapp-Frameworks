import axios from "axios";
import moment from "moment";
import { AuthDataKeys } from "../StorageService";

export async function getDevicePin(oAuthConfig) {
  const clientId = oAuthConfig?.clientId;
  const deviceEndPoint = oAuthConfig?.deviceEndPoint;
  console.log({ oAuthConfig, clientId, deviceEndPoint });
  try {
    const request = {
      url: deviceEndPoint,
      method: "POST",
      headers: {
        "Content-Type": "x-www-form-urlencoded",
      },
      params: {
        client_id: clientId,
      },
    };

    const response = await axios(request);
    console.log({ response });
    return response?.data;
  } catch (error) {
    console.log({ error });
  }
}

export async function getDeviceToken(oAuthConfig, device_code) {
  console.log("getDeviceToken", { oAuthConfig, device_code });
  const clientId = oAuthConfig?.clientId;
  const tokenEndPoint = oAuthConfig?.tokenEndPoint;

  try {
    const request = {
      url: tokenEndPoint,
      method: "POST",
      headers: {
        "Content-Type": "x-www-form-urlencoded",
      },
      params: {
        grant_type: "urn:ietf:params:oauth:grant-type:device_code",
        client_id: clientId,
        device_code: device_code,
      },
    };

    const response = await axios(request);
    console.log("getDeviceToken - response", { response });

    const data = response?.data;

    return {
      ...data,
      [AuthDataKeys.expires_in]: moment().unix() + data.expires_in,
    };
  } catch (error) {
    throw error;
  }
}

export async function getRefreshToken(oAuthConfig, refresh_token) {
  const clientId = oAuthConfig?.clientId;
  const refreshEndPoint = oAuthConfig?.refreshEndPoint;
  console.log({ oAuthConfig, clientId, refreshEndPoint });
  try {
    const request = {
      url: refreshEndPoint,
      method: "POST",
      headers: {
        "Content-Type": "x-www-form-urlencoded",
      },
      params: {
        client_id: clientId,
        [AuthDataKeys.refresh_token]: refresh_token,
      },
    };

    const response = await axios(request);
    console.log({ response });
    return {
      ...data,
      [AuthDataKeys.expires_in]: moment().unix() + data.expires_in,
    };
  } catch (error) {
    throw error;
  }
}

//TODO:Ask Ran
export async function pleaseLogOut(oAuthConfig, access_token) {
  const clientId = oAuthConfig?.clientId;
  const logoutEndPoint = oAuthConfig?.logoutEndPoint;
  if (!logoutEndPoint) {
    //TODO: add logs
    return;
  }
  console.log({ oAuthConfig, clientId, logoutEndPoint });
  try {
    const request = {
      url: refreshEndPoint,
      method: "POST",
      headers: {
        "Content-Type": "x-www-form-urlencoded",
      },
      params: {
        client_id: clientId,
        [AuthDataKeys.access_token]: access_token,
      },
    };

    const response = await axios(request);
    console.log({ response });
    return {
      ...data,
      [AuthDataKeys.expires_in]: moment().unix() + data.expires_in,
    };
  } catch (error) {
    throw error;
  }
}
