import * as R from "ramda";
import { DataModel } from "../../../models";
import {
  saveFlowVersion,
  getFlowVersion,
  removeFlowVersion,
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

export function prepareData(general, rivers) {
  let data: Array<DataModel> = [];
  for (let index = 1; index <= 5; index++) {
    const screenId = general[`screen_selector_${index}`];
    const dataModel = dataModelFromScreenData(screenId, rivers);
    if (dataModel) {
      data.push(dataModel);
    }
  }
  return data;
}

function dataModelFromScreenData(screenId?: string, rivers?: any): DataModel {
  if (R.not(R.isNil(screenId)) && R.not(R.isEmpty(screenId))) {
    const Screen: any = pluginByScreenId({
      rivers,
      screenId: screenId,
    });

    return { screenId, Screen };
  }
  return null;
}
export async function saveScreenFinishedState(flow_version = 1) {
  const flowVersionString = flow_version.toString();
  if (!flowVersionString) {
    logger.warning({
      message: `saveScreenFinishedState: required parameter ${flow_version} is missing`,
      data: {
        flow_version,
        flowVersionString,
      },
    });
    return;
  }
  logger.debug({
    message: `Save data to local storage: ${flow_version}`,
    data: {
      flow_version,
    },
  });
  return await saveFlowVersion(flow_version);
}

export async function removeScreenFinishedState() {
  logger.debug({
    message: `Remove data from local storage`,
  });
  await removeFlowVersion();
}

export async function screenShouldBePresented(
  flow_version = 1
): Promise<boolean> {
  const flowVersionNumber = flow_version;
  const storedFlowVersion = await getFlowVersion();
  const storedFlowVersionNumber =
    storedFlowVersion && Number(storedFlowVersion);

  if (!flowVersionNumber || !storedFlowVersionNumber) {
    logger.debug({
      message: `screenShouldBePresented: true`,
      data: {
        screen_should_be_presented: "true",
        flow_version,
        storedFlowVersion,
        storedFlowVersionNumber,
      },
    });
    return true;
  }

  const result = flowVersionNumber > storedFlowVersionNumber;

  logger.debug({
    message: `screenShouldBePresented: ${result}, flow_version: ${flow_version}, storedFlowVersion: ${storedFlowVersion}`,
    data: {
      screen_should_be_presented: result,
      storedFlowVersion,
      flow_version,
      flowVersionNumber,
      storedFlowVersionNumber,
    },
  });
  return result;
}
