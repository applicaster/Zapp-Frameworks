import moment from "moment";
import * as R from "ramda";
import { Alert } from "react-native";
import { isWebBasedPlatform } from "../../Utils/Platform";
import {
  AuthDataKeys,
  storageGet,
  saveDataToStorages,
} from "../../Services/StorageService";
import { getRefreshToken } from "../../Services/OAuth2Service";

export const getRiversProp = (key, rivers = {}, screenId = "") => {
  const getPropByKey = R.compose(
    R.prop(key),
    R.find(R.propEq("id", screenId)),
    R.values
  );

  return getPropByKey(rivers);
};

export const ScreenData = {
  UNDEFINED: "Undefined",
  INTRO: "Intro",
  LOG_IN: "Login",
  LOG_OUT: "Logout",
  LOADING: "Loading",
};

import {
  createLogger,
  BaseSubsystem,
  BaseCategories,
} from "../../Services/LoggerService";

const logger = createLogger({
  subsystem: BaseSubsystem,
  category: BaseCategories.GENERAL,
});

export function isPlayerHook(payload) {
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

export const isAuthenticationRequired = (payload) => {
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

export function isTokenExpired(expiresIn) {
  return moment(expiresIn).isSameOrAfter();
}

export async function refreshToken(oAuthConfig) {
  try {
    console.log({ oAuthConfig });
    const expiresIn = await storageGet(AuthDataKeys.expires_in);
    const refresh_token = await storageGet(AuthDataKeys.refresh_token);

    const expired = isTokenExpired(parseInt(expiresIn));
    if (expired) {
      logger.debug({
        message: `refreshToken: before refresh`,
        data: {
          is_token_expired: expired,
          expires_in: expiresIn,
          refresh_token: refresh_token,
        },
      });
      const loginData = await getRefreshToken(oAuthConfig, refresh_token);

      await saveDataToStorages(loginData);

      logger.debug({
        message: `refreshToken: completed`,
        data: { refresh_result: refreshResult, login_data: loginData },
      });
    } else {
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
    logger.warning({
      message: `refreshToken: error`,
      data: { error },
    });
    throw error;
  }
}
export async function isLoginRequired() {
  try {
    const accessToken = await storageGet(AuthDataKeys.access_token);

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

export function showAlert(title, message) {
  isWebBasedPlatform
    ? window.alert(`${title} \n${message}`)
    : Alert.alert(title, message);
}
