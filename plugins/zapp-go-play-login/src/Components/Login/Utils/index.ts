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

export async function refreshToken(): Promise<boolean> {
  try {
    const loginData: LoginData = await localStorageGetLoginData();

    if (isTokenExpired(loginData.expires_in)) {
      const refreshResult = await refresh(loginData.refresh_token);
      loginData.access_token = refreshResult.access_token;
      loginData.id_token = refreshResult.id_token;
      loginData.expires_in = moment().unix() + refreshResult.expires_in;

      await localStorageSetLoginData(loginData);
      await syncSessionWithLocalStorage(loginData);

      console.log({ refreshResult });
    }
    return true;
  } catch (error) {
    throw error;
  }
}

export async function saveLoginDataToSessionStorage(): Promise<boolean> {
  try {
    const loginData = await localStorageGetLoginData();

    await syncSessionWithLocalStorage(loginData);
    return true;
  } catch (error) {
    console.log({ error });
    return false;
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
    console.log({ error });
    return false;
  }
}

export async function isLoginRequired(): Promise<boolean> {
  try {
    const loginData = await localStorageGetLoginData();
    const title = moment
      .unix(loginData.expires_in)
      .format("dddd, MMMM Do - hh:mm");
    console.log({
      title,
      isSameOrAfter: moment(loginData.expires_in).isSameOrBefore(),
    });
    if (!loginData.access_token) {
      return true;
    }

    return false;
  } catch (error) {
    return true;
  }
}
export async function saveLoginDataToLocalStorage(jsonString: string) {
  try {
    const parsedData: LoginData = JSON.parse(jsonString);
    if (parsedData) {
      console.log({ parsedData });

      await localStorageSetLoginData(parsedData);

      await syncSessionWithLocalStorage(parsedData);
    }
  } catch (error) {
    console.log({ error });
  }
}

// export async function updatePresentedInfo() {
//   const currentVersionName = await getBuildNumber();
//   logger.debug({
//     message: `Save data to local storage: ${currentVersionName}`,
//     data: {
//       current_version_name: currentVersionName,
//     },
//   });
//   return await localStorageSet(currentVersionName);
// }

// export async function removePresentedInfo() {
//   logger.debug({
//     message: `Remove data from local storage`,
//   });
//   await localStorageRemove();
// }

// export async function screenShouldBePresented(
//   present_on_each_new_version = false
// ): Promise<boolean> {
//   const currentVersionName = await getBuildNumber();
//   const storedVersionName = await localStorageGet();
//   const result = present_on_each_new_version
//     ? currentVersionName !== storedVersionName
//     : R.isNil(storedVersionName);

//   logger.debug({
//     message: `Screen should be presented: ${result}, currentVersionName:${currentVersionName}, storedVersionName:${storedVersionName}`,
//     data: {
//       screen_should_be_presented: result,
//       current_version_name: currentVersionName,
//       stored_version_name: storedVersionName,
//     },
//   });
//   return result;
// }
