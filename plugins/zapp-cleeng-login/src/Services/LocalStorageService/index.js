import { localStorage } from "@applicaster/zapp-react-native-bridge/ZappStorage/LocalStorage";

const localStorageNamespace = "zapp-cleeng-login";

export async function localStorageSet(key, value) {
  return await localStorage.setItem(key, value, localStorageNamespace);
}

export async function localStorageRemove(key) {
  return await localStorage.removeItem(key, localStorageNamespace);
}

export async function localStorageGet(key) {
  return await localStorage.getItem(key, localStorageNamespace);
}

export async function localStorageSetUserAccount(key, value) {
  return await localStorage.setItem(key, value);
}

export async function localStorageRemoveUserAccount(key) {
  return await localStorage.removeItem(key);
}
