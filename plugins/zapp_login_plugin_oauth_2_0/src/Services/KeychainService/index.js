import { localStorage } from "@applicaster/zapp-react-native-bridge/ZappStorage/LocalStorage";
import { sessionStorage } from "@applicaster/zapp-react-native-bridge/ZappStorage/SessionStorage";

import { parseJsonIfNeeded } from "@applicaster/zapp-react-native-utils/functionUtils";
import {
  createLogger,
  BaseSubsystem,
  BaseCategories,
  XRayLogLevel,
} from "../LoggerService";

const namespace = "zapp_login_plugin_oauth_2_0";
const authDataKey = "authData";

export const logger = createLogger({
  subsystem: `${BaseSubsystem}/${BaseCategories.KEYCHAIN_STORAGE}`,
  category: BaseCategories.KEYCHAIN_STORAGE,
});

export async function saveKeychainData(
  data,
  session_storage_key = "access_token"
) {
  const stringifiedData = JSON.stringify(data);
  try {
    const result = await localStorage.setKeychainItem(
      authDataKey,
      stringifiedData,
      namespace
    );
    const accessToken = data?.accessToken;
    if (accessToken) {
      await sessionStorage.setItem(session_storage_key, accessToken, namespace);
    }
    logger
      .createEvent()
      .setLevel(XRayLogLevel.debug)
      .setMessage(`saveKeychainData: Success`)
      .addData({
        namespace,
        auth_data_key: authDataKey,
        session_storage_key,
      })
      .send();
    return result;
  } catch (error) {
    logger
      .createEvent()
      .setLevel(XRayLogLevel.error)
      .setMessage(`saveKeychainData: Error`)
      .addData({
        namespace,
        auth_data_key: authDataKey,
        error,
        session_storage_key,
      })
      .send();
    return false;
  }
}

export async function loadKeychainData() {
  try {
    const stringifiedData = await localStorage.getKeychainItem(
      authDataKey,
      namespace
    );
    const data = parseJsonIfNeeded(stringifiedData);
    logger
      .createEvent()
      .setLevel(XRayLogLevel.debug)
      .setMessage(`loadKeychainData: Success`)
      .addData({
        namespace,
        auth_data_key: authDataKey,
      })
      .send();
    return data;
  } catch (error) {
    logger
      .createEvent()
      .setLevel(XRayLogLevel.error)
      .setMessage(`loadKeychainData: Error`)
      .addData({
        error,
        namespace,
        auth_data_key: authDataKey,
      })
      .send();
    return null;
  }
}

export async function removeKeychainData(session_storage_key = "access_token") {
  try {
    const result = await localStorage.removeKeychainItem(
      authDataKey,
      namespace
    );
    await sessionStorage.removeItem(session_storage_key, namespace);
    logger
      .createEvent()
      .setLevel(XRayLogLevel.debug)
      .setMessage(`removeKeychainData: Success`)
      .addData({
        auth_data_key: authDataKey,
        namespace,
        result,
        session_storage_key,
      })
      .send();
  } catch (error) {
    logger
      .createEvent()
      .setLevel(XRayLogLevel.error)
      .setMessage(`removeKeychainData: Error`)
      .addData({
        error,
        namespace,
        auth_data_key: authDataKey,
        session_storage_key,
      })
      .send();
  }
}
