import * as R from "ramda";
// import { DataModel } from "../../../models";
import {
  localStorageSet,
  localStorageGet,
  localStorageRemove,
  // getBuildNumber,
} from "../../../Services/LocalStorageService";

const logger = createLogger({
  subsystem: BaseSubsystem,
  category: BaseCategories.GENERAL,
});

import {
  createLogger,
  BaseSubsystem,
  BaseCategories,
} from "../../../Services/LoggerService";

export const getRiversProp = (key, rivers = {}, screenId = "") => {
  const getPropByKey = R.compose(
    R.prop(key),
    R.find(R.propEq("id", screenId)),
    R.values
  );

  return getPropByKey(rivers);
};

export function pluginByScreenId({ rivers, screenId }) {
  let plugin = null;
  if (screenId && screenId?.length > 0) {
    plugin = rivers?.[screenId];
  }

  return plugin || null;
}

// export async function updatePresentedInfo() {
//   const currentVersionName = await getBuildNumber();
//   logger.debug({
//     message: `Save data to local storage: ${currentVersionName}`,
//     data: {
//       current_version_name: currentVersionName,
//     },
//   });
//   return await localStorageSet(currentVersionName);
// }

// export async function removePresentedInfo() {
//   logger.debug({
//     message: `Remove data from local storage`,
//   });
//   await localStorageRemove();
// }

// export async function screenShouldBePresented(
//   present_on_each_new_version = false
// ): Promise<boolean> {
//   const currentVersionName = await getBuildNumber();
//   const storedVersionName = await localStorageGet();
//   const result = present_on_each_new_version
//     ? currentVersionName !== storedVersionName
//     : R.isNil(storedVersionName);

//   logger.debug({
//     message: `Screen should be presented: ${result}, currentVersionName:${currentVersionName}, storedVersionName:${storedVersionName}`,
//     data: {
//       screen_should_be_presented: result,
//       current_version_name: currentVersionName,
//       stored_version_name: storedVersionName,
//     },
//   });
//   return result;
// }
