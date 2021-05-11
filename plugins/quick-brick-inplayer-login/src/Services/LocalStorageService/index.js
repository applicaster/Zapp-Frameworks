import { localStorage } from "@applicaster/zapp-react-native-bridge/ZappStorage/LocalStorage";
import { sessionStorage } from "@applicaster/zapp-react-native-bridge/ZappStorage/SessionStorage";

const localStorageNamespace = "quick-brick-inplayer";
const screenWasPresentedKey = "screenWasPresented";

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

export async function getBuildNumber() {
  return await sessionStorage.getItem("version_name");
}

export async function localStorageSaveScreenWasPresented(versionName) {
  return await localStorage.setItem(
    screenWasPresentedKey,
    versionName,
    localStorageNamespace
  );
}

export async function localStorageRemoveScreenPresented() {
  return await localStorage.removeItem(
    screenWasPresentedKey,
    localStorageNamespace
  );
}

export async function localStorageGetScreenWasPresented() {
  return await localStorage.getItem(
    screenWasPresentedKey,
    localStorageNamespace
  );
}
