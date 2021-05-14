import * as R from "ramda";
import { LoginData, LoginDataKeys } from "../../../models/Response";
import moment from "moment";
import { refresh } from "./authorize";
const {
  client_id,
  access_token,
  expires_in,
  refresh_token,
  user_email,
  user_first_name,
  user_last_name,
  selligent_id,
  id_token,
} = LoginDataKeys;

import {
  localStorageSetLoginData,
  localStorageGetLoginData,
  localStorageRemoveLoginData,
} from "../../../Services/LocalStorageService";

import { sessionStorageSet } from "../../../Services/SessionStorageService";
const logger = createLogger({
  subsystem: BaseSubsystem,
  category: BaseCategories.GENERAL,
});

import {
  createLogger,
  BaseSubsystem,
  BaseCategories,
} from "../../../Services/LoggerService";

export const getRiversProp = (key, rivers = {}, screenId = "") => {
  const getPropByKey = R.compose(
    R.prop(key),
    R.find(R.propEq("id", screenId)),
    R.values
  );

  return getPropByKey(rivers);
};

export function pluginByScreenId({ rivers, screenId }) {
  let plugin = null;
  if (screenId && screenId?.length > 0) {
    plugin = rivers?.[screenId];
  }

  return plugin || null;
}

export function isTokenExpired(token: number): boolean {
  return moment(token).isSameOrBefore();
}

export async function refreshToken(clientId, region): Promise<boolean> {
  try {
    const loginData: LoginData = await localStorageGetLoginData();

    if (isTokenExpired(loginData.expires_in)) {
      logger.debug({
        message: `refreshToken: before refresh`,
        data: { login_data: loginData, is_token_expired: isTokenExpired },
      });
      const refreshResult = await refresh(
        loginData.refresh_token,
        clientId,
        region
      );
      loginData.access_token = refreshResult.access_token;
      loginData.id_token = refreshResult.id_token;
      loginData.expires_in = moment().unix() + refreshResult.expires_in;

      await localStorageSetLoginData(loginData);
      await syncSessionWithLocalStorage(loginData);

      logger.debug({
        message: `refreshToken: completed`,
        data: { refresh_result: refreshResult, login_data: loginData },
      });
    }
    return true;
  } catch (error) {
    logger.warning({
      message: `refreshToken: error`,
      data: { error },
    });
    throw error;
  }
}

export async function saveLoginDataToSessionStorage(): Promise<boolean> {
  try {
    const loginData = await localStorageGetLoginData();

    await syncSessionWithLocalStorage(loginData);
    return true;
  } catch (error) {
    logger.warning({
      message: `saveLoginDataToSessionStorage: error`,
      data: { error },
    });
    throw error;
  }
}
export async function syncSessionWithLocalStorage(params: LoginData) {
  try {
    await sessionStorageSet(client_id, params.client_id);
    await sessionStorageSet(access_token, params.access_token);
    await sessionStorageSet(expires_in, params.expires_in.toString());
    await sessionStorageSet(refresh_token, params.refresh_token);
    await sessionStorageSet(user_first_name, params.user_first_name);
    await sessionStorageSet(user_last_name, params.user_last_name);
    await sessionStorageSet(user_email, params.user_email);
    await sessionStorageSet(selligent_id, params.selligent_id);
    await sessionStorageSet(id_token, params.id_token);
    return true;
  } catch (error) {
    logger.warning({
      message: `syncSessionWithLocalStorage: error`,
      data: { error },
    });
    throw error;
  }
}

export async function isLoginRequired(): Promise<boolean> {
  try {
    const loginData = await localStorageGetLoginData();
    logger.info({
      message: `isLoginRequired: ${loginData && !loginData.access_token}`,
      data: {
        login_data: loginData,
        is_login_required: loginData && !loginData.access_token,
      },
    });
    return loginData && !loginData.access_token;
  } catch (error) {
    logger.warning({
      message: `isLoginRequired: error`,
      data: { error },
    });
    throw error;
  }
}
export async function saveLoginDataToLocalStorage(jsonString: string) {
  try {
    const parsedData: LoginData = JSON.parse(jsonString);
    if (parsedData) {
      await localStorageSetLoginData(parsedData);
      await syncSessionWithLocalStorage(parsedData);
    }
    logger.info({
      message: `saveLoginDataToLocalStorage: completed`,
      data: { parsedData },
    });
  } catch (error) {
    logger.warning({
      message: `saveLoginDataToLocalStorage: error`,
      data: { error },
    });
    throw error;
  }
}
