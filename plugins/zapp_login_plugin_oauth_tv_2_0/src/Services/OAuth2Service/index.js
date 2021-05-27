import axios from "axios";
import moment from "moment";
import { AuthDataKeys } from "../StorageService";
import { createLogger, BaseSubsystem, BaseCategories } from "../LoggerService";

const logger = createLogger({
  subsystem: BaseSubsystem,
  category: BaseCategories.GENERAL,
});

export async function getDevicePin(oAuthConfig) {
  const clientId = oAuthConfig?.clientId;
  const deviceEndPoint = oAuthConfig?.deviceEndPoint;
  logger.debug({
    message: "getDevicePin: before",
  });
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
    logger.debug({
      message: "getDevicePin: completed",
      data: { clientId, deviceEndPoint, oAuthConfig, response },
    });
    const data = response?.data;
    console.log({ response });
    return data;
  } catch (error) {
    logger.error({
      message: `getDevicePin: error, message: ${error?.message}`,
      data: { clientId, deviceEndPoint, oAuthConfig, error },
    });
    throw error;
  }
}

export async function getDeviceToken(oAuthConfig, device_code) {
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
    const newData = {
      ...data,
      [AuthDataKeys.expires_in]: moment().unix() + data.expires_in,
    };
    logger.debug({
      message: "getDeviceToken: completed",
      data: {
        clientId,
        tokenEndPoint,
        oAuthConfig,
        device_code,
        response,
        newData,
      },
    });
    return newData;
  } catch (error) {
    logger.debug({
      message: `getDeviceToken: error, message: ${error?.message}`,
      data: {
        clientId,
        tokenEndPoint,
        oAuthConfig,
        device_code,
        error,
      },
    });
    throw error;
  }
}

export async function getRefreshToken(oAuthConfig, refresh_token) {
  const clientId = oAuthConfig?.clientId;
  const refreshEndPoint = oAuthConfig?.refreshEndPoint;
  if (!refreshEndPoint) {
    logger.debug({
      message: "getRefreshToken: completed, no refresh end point provided",
      data: {
        clientId,
        refreshEndPoint,
        oAuthConfig,
        refresh_token,
      },
    });
    return null;
  }
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
    const data = response?.data;
    const newData = {
      ...data,
      [AuthDataKeys.expires_in]: moment().unix() + data.expires_in,
    };
    logger.debug({
      message: "getRefreshToken: completed",
      data: {
        clientId,
        refreshEndPoint,
        oAuthConfig,
        refresh_token,
        newData,
        response,
      },
    });
    return newData;
  } catch (error) {
    logger.error({
      message: `getRefreshToken: error, message: ${error?.message}`,
      data: {
        clientId,
        refreshEndPoint,
        oAuthConfig,
        refresh_token,
        error,
      },
    });
    throw error;
  }
}

export async function pleaseLogOut(oAuthConfig, access_token) {
  const clientId = oAuthConfig?.clientId;
  const logoutEndPoint = oAuthConfig?.logoutEndPoint;
  console.log({ logoutEndPoint });
  if (!logoutEndPoint) {
    logger.debug({
      message: "pleaseLogOut: completed, no logout end point provided",
      data: {
        clientId,
        oAuthConfig,
        access_token,
        logoutEndPoint,
      },
    });
    return;
  }
  console.log({ oAuthConfig, clientId, logoutEndPoint });
  try {
    const request = {
      url: logoutEndPoint,
      method: "POST",
      headers: {
        "Content-Type": "x-www-form-urlencoded",
      },
      params: {
        client_id: clientId,
        [AuthDataKeys.access_token]: access_token,
      },
    };

    await axios(request);

    logger.debug({
      message: "pleaseLogOut: completed",
      data: {
        clientId,
        oAuthConfig,
        access_token,
        logoutEndPoint,
        response,
      },
    });
    return true;
  } catch (error) {
    logger.debug({
      message: `pleaseLogOut: Error, message: ${error?.message}`,
      data: {
        clientId,
        oAuthConfig,
        access_token,
        logoutEndPoint,
        error,
      },
    });
    throw error;
  }
}
