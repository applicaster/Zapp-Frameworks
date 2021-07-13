import { Platform } from "react-native";

import createManifest from "../manifests/manifest.config";

const PLATFORMS = ["android_for_quickbrick", "ios_for_quickbrick"];
export const releaseBuild = process.env.with_release || null;

/**
 * Generates a manifest using the current platform, and package version
 * and passes that data to the createManifest method in manifest.config.js
 * We have more elaborate platform utils, but this is ios | android only
 * @returns {Object} the zapp manifest generated
 */
function getManifest() {
  const version = process.env.npm_package_version;
  const platform = PLATFORMS.find((platform) => platform.includes(Platform.OS));

  const manifest = createManifest({ version, platform });
  return manifest;
}

/**
 * Get the value of the given manifest field
 * This method relies on the createManifest method from manifest.config
 * Zapp Frameworks CI does not store the generated manifests so we have to generate on demand
 * This util exists because the CMS does not return default values from manifest
 * @param {string} manifestKey the manifestKey you would like to return i.e. styles, general
 * @param {string} fieldKey the specific field you would like to return i.e. package_name, background_color
 * @returns {*} the value of the manifest key
 */
export function getFromManifest(manifestKey, fieldKey = null) {
  const manifest = getManifest();
  const values = manifest?.[manifestKey];
  const field =
    values?.fields && values.fields.find((field) => field.key === fieldKey);
  return field || values;
}

/**
 * Default values for a given field as they were defined in manifest.config.js
 * Used as a fallback when we do not get any screen data
 */
export const DEFAULT = {
  packageName: getFromManifest("general", "package_name")?.default,
  methodName: getFromManifest("general", "method_name")?.default,
};

export const parseFontKey = (platform) => {
  const endpoints = {
    ios: "tvos",
    android: "android",
    samsung_tv: "samsung",
  };

  return endpoints[platform];
};
