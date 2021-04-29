import { localStorage } from "@applicaster/zapp-react-native-bridge/ZappStorage/LocalStorage";

const localStorageNamespace = "first-time-user-expirience-screen";
const screenWasPresentedKey = "screenWasPresented";
const screenWasPresentedValue = "true";
export async function localStorageSet() {
  console.log("localStorageSet");
  return await localStorage.setItem(
    screenWasPresentedKey,
    screenWasPresentedValue,
    localStorageNamespace
  );
}

export async function localStorageRemove() {
  console.log("localStorageRemove");

  return await localStorage.removeItem(
    screenWasPresentedKey,
    localStorageNamespace
  );
}

export async function localStorageGet(): Promise<boolean> {
  const result = await localStorage.getItem(
    screenWasPresentedKey,
    localStorageNamespace
  );
  console.log("localStorageGet", { result });

  return result === screenWasPresentedValue;
}
