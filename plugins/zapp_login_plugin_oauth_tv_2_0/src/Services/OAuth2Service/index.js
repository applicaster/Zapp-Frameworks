import axios from "axios";

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
    return response?.data;
  } catch (error) {
    throw error;
  }
}
