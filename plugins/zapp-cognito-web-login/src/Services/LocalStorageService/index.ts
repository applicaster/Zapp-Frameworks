import { localStorage } from "@applicaster/zapp-react-native-bridge/ZappStorage/LocalStorage";
import { LoginData, LoginDataKeys } from "../../models/Response";

const localStorageNamespace = "cognito-webview-login";
const loginDataKey = "login-data";

export async function localStorageSet(key: string, value: string) {
  return await localStorage.setItem(key, value, localStorageNamespace);
}

export async function localStorageRemove(key: string) {
  return await localStorage.removeItem(key, localStorageNamespace);
}

export async function localStorageGet(key: string) {
  return await localStorage.getItem(key, localStorageNamespace);
}

export async function localStorageSetLoginData(loginData: LoginData) {
  return await localStorage.setItem(
    loginDataKey,
    loginData,
    localStorageNamespace
  );
}

export async function localStorageRemoveLoginData() {
  return await localStorage.removeItem(loginDataKey, localStorageNamespace);
}

export async function localStorageGetLoginData() {
  return await localStorage.getItem(loginDataKey, localStorageNamespace);
}
