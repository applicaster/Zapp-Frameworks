import * as R from "ramda";
import {
  localStorageSaveScreenWasPresented,
  localStorageRemoveScreenPresented,
  localStorageGetScreenWasPresented,
  getBuildNumber,
} from "../../Services/LocalStorageService";

const logger = createLogger({
  subsystem: BaseSubsystem,
  category: BaseCategories.GENERAL,
});

import {
  createLogger,
  BaseSubsystem,
  BaseCategories,
} from "../../Services/LoggerService";

export async function updatePresentedInfo() {
  const currentVersionName = await getBuildNumber();
  logger.debug({
    message: `Save data to local storage: ${currentVersionName}`,
    data: {
      current_version_name: currentVersionName,
    },
  });
  return await localStorageSaveScreenWasPresented(currentVersionName);
}

export async function removePresentedInfo() {
  logger.debug({
    message: `Remove data from local storage`,
  });
  await localStorageRemoveScreenPresented();
}

export async function screenShouldBePresented() {
  const storedVersionName = await localStorageGetScreenWasPresented();
  const result = R.isNil(storedVersionName);

  logger.debug({
    message: `Screen should be presented: ${result}`,
    data: {
      screen_should_be_presented: result,
      stored_version_name: storedVersionName,
    },
  });
  return result;
}
