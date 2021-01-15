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
  subsystem: `${BaseSubsystem}/${BaseCategories.IAP_SERVICE}`,
  category: BaseCategories.IAP_SERVICE,
});

export async function saveKeychainData(data) {
  const stringifiedData = JSON.stringify(data);
  console.log({ localStorage });
  try {
    await localStorage.setKeychainItem(authDataKey, stringifiedData, namespace);
  } catch (error) {
    console.log(error);
  }
}

export async function loadKeychainData() {
  try {
    const stringifiedData = await localStorage.getKeychainItem(
      authDataKey,
      namespace
    );
    const data = parseJsonIfNeeded(stringifiedData);
    return data;
  } catch (error) {
    console.log(error);
  }
}

export async function removeKeychainData() {
  try {
    await localStorage.removeKeychainItem(authDataKey, namespace);
  } catch (error) {
    console.log(error);
  }
}
