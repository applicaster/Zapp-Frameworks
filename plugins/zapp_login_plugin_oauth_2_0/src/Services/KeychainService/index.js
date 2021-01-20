import { localStorage } from "@applicaster/zapp-react-native-bridge/ZappStorage/LocalStorage";
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

export async function saveKeychainData(data) {
  const stringifiedData = JSON.stringify(data);
  try {
    const result = await localStorage.setKeychainItem(
      authDataKey,
      stringifiedData,
      namespace
    );
    logger
      .createEvent()
      .setLevel(XRayLogLevel.debug)
      .setMessage(`saveKeychainData: Success`)
      .addData({
        data,
        namespace,
        auth_data_key: authDataKey,
      })
      .send();
    return result;
  } catch (error) {
    logger
      .createEvent()
      .setLevel(XRayLogLevel.error)
      .setMessage(`saveKeychainData: Error`)
      .addData({
        data,
        namespace,
        auth_data_key: authDataKey,
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
        data,
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
        data,
        namespace,
        auth_data_key: authDataKey,
      })
      .send();
    return null;
  }
}

export async function removeKeychainData() {
  try {
    const result = await localStorage.removeKeychainItem(
      authDataKey,
      namespace
    );
    logger
      .createEvent()
      .setLevel(XRayLogLevel.debug)
      .setMessage(`removeKeychainData: Success`)
      .addData({
        auth_data_key: authDataKey,
        namespace,
      })
      .send();
    console.log("removeKeychainData", { result });
  } catch (error) {
    logger
      .createEvent()
      .setLevel(XRayLogLevel.error)
      .setMessage(`removeKeychainData: Error`)
      .addData({
        namespace,
        auth_data_key: authDataKey,
      })
      .send();
  }
}
