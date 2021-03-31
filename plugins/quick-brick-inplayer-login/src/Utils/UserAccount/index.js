import * as R from "ramda";

import { parseJsonIfNeeded } from "@applicaster/zapp-react-native-utils/functionUtils";
import { localStorage as storage } from "@applicaster/zapp-react-native-bridge/ZappStorage/LocalStorage";

export const isHook = (navigator) => {
  return !!R.propOr(false, "hookPlugin")(navigator.screenData);
};

export async function removeFromLocalStorage(key, namespace) {
  return storage.setItem(key, JSON.stringify({}), namespace);
}

async function getFromLocalStorage(key, namespace) {
  return storage.getItem(key, namespace);
}

export async function isTokenInStorage(key, namespace) {
  try {
    let token = await getFromLocalStorage(key, namespace);

    if (token === null) return false;

    if (typeof token === "string") {
      token = parseJsonIfNeeded(token);
    }

    if (Array.isArray(token)) return !!token.length;
    if (typeof token === "object") return !R.isEmpty(token);

    return !!token;
  } catch (err) {
    return false;
  }
}
