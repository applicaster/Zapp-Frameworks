import { localStorage } from "@applicaster/zapp-react-native-bridge/ZappStorage/LocalStorage";

const localStorageNamespace = "first-time-user-expirience-screen";
const pluginVersionKey = "plugin_version";

export async function savePluginVersion(version) {
  return await localStorage.setItem(
    pluginVersionKey,
    version,
    localStorageNamespace
  );
}

export async function removePluginVersion() {
  return await localStorage.removeItem(pluginVersionKey, localStorageNamespace);
}

export async function getPluginVersion(): Promise<string> {
  return await localStorage.getItem(pluginVersionKey, localStorageNamespace);
}
