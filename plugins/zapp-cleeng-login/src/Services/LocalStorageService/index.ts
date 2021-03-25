import { localStorage } from "@applicaster/zapp-react-native-bridge/ZappStorage/LocalStorage";

const localStorageNamespace = "zapp-cleeng-login";

export async function localStorageSet(key: string, value: string) {
  return await localStorage.setItem(key, value, localStorageNamespace);
}

export async function localStorageRemove(key: string) {
  return await localStorage.removeItem(key, localStorageNamespace);
}

export async function localStorageGet(key: string) {
  return await localStorage.getItem(key, localStorageNamespace);
}

export async function localStorageSetUserAccount(key: string, value: string) {
  return await localStorage.setItem(key, value);
}

export async function localStorageRemoveUserAccount(key: string) {
  return await localStorage.removeItem(key);
}

export async function localStorageApplicasterGet(key: string) {
  return await localStorage.getItem(key);
}
