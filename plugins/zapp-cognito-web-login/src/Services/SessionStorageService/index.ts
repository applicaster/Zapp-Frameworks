import { sessionStorage } from "@applicaster/zapp-react-native-bridge/ZappStorage/SessionStorage";

const sessionStorageNamespace = "cognito-webview-login";

export async function sessionStorageSet(key: string, value: string) {
  return await sessionStorage.setItem(key, value, sessionStorageNamespace);
}

export async function sessionStorageRemove(key: string) {
  return await sessionStorage.removeItem(key, sessionStorageNamespace);
}

export async function sessionStorageGet(key: string) {
  return await sessionStorage.getItem(key, sessionStorageNamespace);
}
