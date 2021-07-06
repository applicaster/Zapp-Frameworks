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
  localStorageGet,
  localStorageSet,
  localStorageRemove,
} from "../../../Services/LocalStorageService";

import {
  sessionStorageSet,
  sessionStorageRemove,
} from "../../../Services/SessionStorageService";

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

export function isPlayerHook(payload: ZappEntry): boolean {
  if (!payload) {
    return false;
  }

  return R.compose(
    R.propEq("plugin_type", "player"),
    R.prop(["targetScreen"])
  )(payload);
}

export function pluginByScreenId({ rivers, screenId }) {
  let plugin = null;
  if (screenId && screenId?.length > 0) {
    plugin = rivers?.[screenId];
  }

  return plugin || null;
}

export const isHomeScreen = (navigator) => {
  return R.pathOr(false, ["payload", "home"], navigator.screenData);
};

export const isAuthenticationRequired = (payload: ZappEntry) => {
  const requires_authentication = R.path([
    "extensions",
    "requires_authentication",
  ])(payload);

  logger.debug({
    message: `Payload entry is requires_authentication: ${!!requires_authentication}`,
    data: {
      requires_authentication: !!requires_authentication,
    },
  });
  return !!requires_authentication;
};

export function isTokenExpired(expiresIn: number): boolean {
  return expiresIn < moment().unix();
}

export async function refreshToken(clientId, region): Promise<boolean> {
  try {
    const expiresIn = await localStorageGet(expires_in);
    const refreshToken = await localStorageGet(refresh_token);

    const expired = isTokenExpired(parseInt(expiresIn));
    if (expired) {
      logger.debug({
        message: `refreshToken: before refresh`,
        data: {
          is_token_expired: expired,
          expires_in: expiresIn,
          refreshToken: refresh_token,
        },
      });
      const refreshResult = await refresh(refreshToken, clientId, region);

      const loginData: LoginData = {
        access_token: refreshResult.access_token,
        id_token: refreshResult.id_token,
        expires_in: moment().unix() + refreshResult.expires_in,
      };
      await localStorageSetLoginData(loginData);
      await sessionStorageSetLoginData(loginData);

      logger.debug({
        message: `refreshToken: completed`,
        data: { refresh_result: refreshResult, login_data: loginData },
      });
    } else {
      await copyLocalStorageDataToSessionStorage();
      logger.debug({
        message: `refreshToken: completed, no need to refresh`,
        data: {
          is_token_expired: expired,
          expires_in: expiresIn,
          refreshToken: refresh_token,
        },
      });
    }
    return true;
  } catch (error) {
    logger.debug({
      message: `refreshToken: error`,
      data: { error },
    });
    throw error;
  }
}

async function copyLocalStorageDataToSessionStorage() {
  const clientId = await localStorageGet(client_id);
  const accessToken = await localStorageGet(access_token);
  const expiresIn = await localStorageGet(expires_in);
  const refreshToken = await localStorageGet(refresh_token);
  const userFirstName = await localStorageGet(user_first_name);
  const userLastName = await localStorageGet(user_last_name);
  const userEmail = await localStorageGet(user_email);
  const selligentId = await localStorageGet(selligent_id);
  const idToken = await localStorageGet(id_token);

  await sessionStorageSetLoginData({
    client_id: clientId,
    access_token: accessToken,
    expires_in: expiresIn,
    refresh_token: refreshToken,
    user_first_name: userFirstName,
    user_last_name: userLastName,
    user_email: userEmail,
    selligent_id: selligentId,
    id_token: idToken,
  });
}

export async function localStorageSetLoginData(params: LoginData) {
  try {
    params.client_id && (await localStorageSet(client_id, params.client_id));
    params.access_token &&
      (await localStorageSet(access_token, params.access_token));
    params.expires_in &&
      (await localStorageSet(expires_in, params.expires_in.toString()));
    params.refresh_token &&
      (await localStorageSet(refresh_token, params.refresh_token));
    params.user_first_name &&
      (await localStorageSet(user_first_name, params.user_first_name));
    params.user_last_name &&
      (await localStorageSet(user_last_name, params.user_last_name));
    params.user_email && (await localStorageSet(user_email, params.user_email));
    params.selligent_id &&
      (await localStorageSet(selligent_id, params.selligent_id));
    params.id_token && (await localStorageSet(id_token, params.id_token));
    logger.debug({
      message: `localStorageSetLoginData: success`,
      data: { new_data: params },
    });
    return true;
  } catch (error) {
    logger.warning({
      message: `localStorageSetLoginData: error`,
      data: { error },
    });
    throw error;
  }
}
export async function sessionStorageSetLoginData(params: LoginData) {
  try {
    params.client_id && (await sessionStorageSet(client_id, params.client_id));
    params.access_token &&
      (await sessionStorageSet(access_token, params.access_token));
    params.expires_in &&
      (await sessionStorageSet(expires_in, params.expires_in.toString()));
    params.refresh_token &&
      (await sessionStorageSet(refresh_token, params.refresh_token));
    params.user_first_name &&
      (await sessionStorageSet(user_first_name, params.user_first_name));
    params.user_last_name &&
      (await sessionStorageSet(user_last_name, params.user_last_name));
    params.user_email &&
      (await sessionStorageSet(user_email, params.user_email));
    params.selligent_id &&
      (await sessionStorageSet(selligent_id, params.selligent_id));
    params.id_token && (await sessionStorageSet(id_token, params.id_token));
    logger.debug({
      message: `sessionStorageSetLoginData: success`,
      data: { new_data: params },
    });
    return true;
  } catch (error) {
    logger.warning({
      message: `sessionStorageSetLoginData: error`,
      data: { error },
    });
    throw error;
  }
}

export async function isLoginRequired(): Promise<boolean> {
  try {
    const accessToken = await localStorageGet(access_token);

    if (accessToken) {
      const is_login_required = !!accessToken === false;
      logger.info({
        message: `isLoginRequired: ${is_login_required}`,
        data: {
          access_token: !!accessToken === false,
          is_login_required: !!is_login_required,
        },
      });
      return is_login_required;
    } else {
      logger.info({
        message: `isLoginRequired: no data in local storage`,
        data: {
          is_login_required: true,
        },
      });
      return true;
    }
  } catch (error) {
    logger.warning({
      message: `isLoginRequired: error`,
      data: { error },
    });
    throw error;
  }
}
export async function removeDataFromStorages() {
  await localStorageRemove(client_id);
  await localStorageRemove(access_token);
  await localStorageRemove(expires_in);
  await localStorageRemove(refresh_token);
  await localStorageRemove(user_first_name);
  await localStorageRemove(user_last_name);
  await localStorageRemove(user_email);
  await localStorageRemove(selligent_id);
  await localStorageRemove(id_token);

  await sessionStorageRemove(client_id);
  await sessionStorageRemove(access_token);
  await sessionStorageRemove(expires_in);
  await sessionStorageRemove(refresh_token);
  await sessionStorageRemove(user_first_name);
  await sessionStorageRemove(user_last_name);
  await sessionStorageRemove(user_email);
  await sessionStorageRemove(selligent_id);
  await sessionStorageRemove(id_token);

  logger.debug({
    message: `removeDataFromStorages: success`,
  });
}

export async function saveLoginDataToStorages(data) {
  try {
    const parsedData: LoginData = data;
    if (parsedData) {
      await localStorageSetLoginData(parsedData);
      await sessionStorageSetLoginData(parsedData);
    }
    logger.info({
      message: `saveLoginDataToStorages: completed`,
      data: { parsed_data: parsedData },
    });
  } catch (error) {
    logger.warning({
      message: `saveLoginDataToStorages: error`,
      data: { error },
    });
    throw error;
  }
}
