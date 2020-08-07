import * as R from "ramda";
import { parseJsonIfNeeded } from "@applicaster/zapp-react-native-utils/functionUtils";
import { localStorage as storage } from "@applicaster/zapp-react-native-bridge/ZappStorage/LocalStorage";
import { fontsize, fontcolor } from "../Styles/DefaultStyles";

export function getPluginData(screenData) {
  let pluginData = {};

  if (screenData && screenData.general) {
    pluginData = { ...pluginData, ...screenData.general };
    validateStyles(pluginData);
  }

  return pluginData;
}

export async function getFromLocalStorage(key, namespace) {
  return storage.getItem(key, namespace);
}

export async function isItemInStorage(key, namespace) {
  try {
    const nameSpaceToUse =
      namespace && namespace.length !== 0 ? namespace : null;

    let item = await getFromLocalStorage(key, nameSpaceToUse);

    if (!item) {
      item = await getFromLocalStorage(key, null);
    }

    if (item === null) return false;

    if (typeof item === "string") {
      item = parseJsonIfNeeded(item);
    }

    if (Array.isArray(item)) return !!item.length;
    if (typeof item === "object") return !R.isEmpty(item);

    return !!item;
  } catch (err) {
    console.log(err);
    return false;
  }
}

function validateStyles(pluginData) {
  const keys = Object.keys(pluginData);

  keys.forEach((key) => {
    const type = key.split("_").pop();

    if (type === "fontsize" || type === "fontcolor") {
      validateKey(type, key, pluginData);
    }
  });
}

function validateKey(type, key, pluginData) {
  const keysValidation = {
    fontsize: validateFontsize,
    fontcolor: validateFontcolor,
  };

  return keysValidation[type](key, pluginData);
}

const validateFontsize = (key, pluginData) => {
  const value = pluginData[key];
  const keyname = R.replace("_fontsize", "", key);

  const num = Number(value);
  pluginData[key] = Number.isFinite(num) ? num : fontsize[keyname];
};

const validateFontcolor = (key, pluginData) => {
  const value = pluginData[key];
  const keyname = R.replace("_fontcolor", "", key);

  pluginData[key] =
    value !== undefined && value !== null ? value : fontcolor[keyname];
};
