import * as R from "ramda";

import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";
import { populateConfigurationValues } from "@applicaster/zapp-react-native-utils/stylesUtils";
import MESSAGES from "../../Components/AssetFlow/Config";

const manifestJson = platformSelect({
  ios: require("../../../manifests/ios_for_quickbrick.json"),
  tvos: require("../../../manifests/tvos_for_quickbrick.json"),
  android: require("../../../manifests/android.json"),
  android_tv: require("../../../manifests/android_tv_for_quickbrick.json"),
  web: require("../../../manifests/samsung_tv.json"),
  samsung_tv: require("../../../manifests/samsung_tv.json"),
  // lg_tv: require("../../../manifests/lg_tv.json"),
  default: require("../../../manifests/android.json"),
});

export function pluginIdentifier() {
  return manifestJson.identifier;
}

export let styles = null;
export function getStyles(screenStyles) {
  return styles ? styles : prepareStyles(screenStyles);
}

export function prepareStyles(screenStyles) {
  styles = populateConfigurationValues(manifestJson.styles.fields)(
    screenStyles
  );
  styles.import_parent_lock = screenStyles.import_parent_lock
    ? screenStyles.import_parent_lock
    : false;

  return styles;
}

export const isHomeScreen = (navigator) => {
  return R.pathOr(false, ["payload", "home"], navigator.screenData);
};

const mapInputKeyToStyle = (key, obj) => {
  return {
    backgroundColor: obj?.[`${key}_background`],
    backgroundColor_filled: obj?.[`${key}_background_filled`],
    backgroundColor_focused: obj?.[`${key}_background_focused`],
    borderColor: obj?.[`${key}_border_color`],
    borderColor_filled: obj?.[`${key}_border_color_filled`],
    borderColor_focused: obj?.[`${key}_border_color_focused`],
    placeholderTextColor: obj?.[`${key}_placeholder_color`]
  }
}

export const mapKeyToStyle = R.curry((key, obj) => {
  const isInputKey = key.includes('input');
  const inputStyleObj = isInputKey ? mapInputKeyToStyle(key, obj) : null;

  return {
    fontFamily: platformSelect({
      ios: obj?.[`${key}_font_ios`],
      android: obj?.[`${key}_font_android`],
      tvos: obj?.[`${key}_font_tvos`],
      android_tv: obj?.[`${key}_font_android_tv`],
      web: obj?.[`${key}_font_web`],
      samsung_tv: obj?.[`${key}_font_samsung_tv`],
      lg_tv: obj?.[`${key}_font_lg_tv`],
    }),
    fontSize: obj?.[`${key}_fontsize`],
    color: obj?.[`${key}_fontcolor`],
    ... isInputKey && inputStyleObj,
  };
});

export const withEndSpace = (str) => {
  return `${str}\xa0`; // explicitly add space after string
};

export function inputFieldStyle(screenStyles) {
  return {
    fontFamily: platformSelect({
      ios: screenStyles?.fields_font_ios,
      android: screenStyles?.fields_font_android,
    }),
    fontSize: screenStyles?.fields_font_size,
    color: screenStyles?.fields_font_color,
    backgroundColor: "transparent",
    width: 250,
    height: 50,
    borderBottomWidth: 1,
    borderBottomColor: screenStyles?.fields_separator_color || "#A9A9A9",
    marginBottom: 10,
    paddingHorizontal: 15,
    alignSelf: "center",
  };
}

export function getMessageOrDefault(error, screenLocalizations) {
  const message = error?.message;
  const defaultMessage = screenLocalizations.general_error_message;

  const isStreamException = isStreamExceptionError(message, screenLocalizations);
  if (isStreamException) return message;

  const isUserFriendlyMessage = findInObject(MESSAGES, message);
  return isUserFriendlyMessage ? message : defaultMessage;
}

function isStreamExceptionError(message, screenLocalizations) {
  const streamExceptionMessage = screenLocalizations.video_stream_exception_message;
  return message === streamExceptionMessage;
}

function findInObject(obj, condition) {
  return Object.values(obj).some((value) => {
    if (Array.isArray(value) || (typeof value === "object" && value !== null)) {
      return findInObject(value, condition);
    }
    return value === condition;
  });
}

export const pickByKey = (key) =>
  R.pickBy((val, _key) => R.includes(key, _key));

const normalizeKeys = (obj) => {
  const objEntries = Object.entries(obj).map(([key, val]) => {
    const keyArr = key.split('_');
    keyArr.pop();
    return [keyArr.join('_'), val]
  });
  return Object.fromEntries(objEntries);
}

export const splitInputTypeStyles = (styles) => {
  const focused = pickByKey("_focused")(styles);
  const filled = pickByKey("_filled")(styles);
  const _default = R.omit([...R.keys(filled), ...R.keys(focused)])(styles);

  return {
    focused: normalizeKeys(focused),
    filled: normalizeKeys(filled),
    default: _default,
  };
};
