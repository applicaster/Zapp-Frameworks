import { localStorage } from "@applicaster/zapp-react-native-bridge/ZappStorage/LocalStorage";

const localStorageNamespace = "first-time-user-expirience-screen";
const screenWasPresentedKey = "screenWasPresented";

export async function getBuildNumber() {
  return await localStorage.getItem("version_name");
}

export async function localStorageSet(versionName) {
  console.log("localStorageSet");
  return await localStorage.setItem(
    screenWasPresentedKey,
    versionName,
    localStorageNamespace
  );
}

export async function localStorageRemove() {
  return await localStorage.removeItem(
    screenWasPresentedKey,
    localStorageNamespace
  );
}

export async function localStorageGet(): Promise<boolean> {
  return await localStorage.getItem(
    screenWasPresentedKey,
    localStorageNamespace
  );
}
