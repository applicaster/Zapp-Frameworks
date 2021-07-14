import { localStorage } from "@applicaster/zapp-react-native-bridge/ZappStorage/LocalStorage";

const localStorageNamespace = "first-time-user-expirience-screen";
const flowVersionKey = "flow_version";

export async function saveFlowVersion(version) {
  return await localStorage.setItem(
    flowVersionKey,
    version,
    localStorageNamespace
  );
}

export async function removeFlowVersion() {
  return await localStorage.removeItem(flowVersionKey, localStorageNamespace);
}

export async function getFlowVersion(): Promise<string> {
  return await localStorage.getItem(flowVersionKey, localStorageNamespace);
}
