import { localStorage } from "@applicaster/zapp-react-native-bridge/ZappStorage/LocalStorage";
import { sessionStorage } from "@applicaster/zapp-react-native-bridge/ZappStorage/SessionStorage";

const namespace = "zapp_login_plugin_oauth_tv_2_0";

export const AuthDataKeys = {
  access_token: "access_token",
  id_token: "id_token",
  refresh_token: "refresh_token",
  expires_in: "expires_in",
};

export async function saveDataToStorages(data) {
  const access_token = data?.access_token;
  await saveToStorages(AuthDataKeys.access_token, access_token);

  const id_token = data?.id_token;
  await saveToStorages(AuthDataKeys.id_token, id_token);

  const refresh_token = data?.refresh_token;
  await saveToStorages(AuthDataKeys.refresh_token, refresh_token);

  const expires_in = data?.expires_in;
  await saveToStorages(AuthDataKeys.expires_in, expires_in);
}

export async function saveToStorages(key, value) {
  await localStorage.setItem(key, value, namespace);
  await sessionStorage.setItem(key, value, namespace);
}

export async function removeDataFromStorages() {
  await localStorage.removeItem(AuthDataKeys.access_token, namespace);
  await localStorage.removeItem(AuthDataKeys.id_token, namespace);
  await localStorage.removeItem(AuthDataKeys.refresh_token, namespace);
  await localStorage.removeItem(AuthDataKeys.expires_in, namespace);
}

export async function storageGet(key) {
  return await localStorage.getItem(key, namespace);
}
