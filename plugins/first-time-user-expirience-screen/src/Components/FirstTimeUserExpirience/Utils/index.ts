import * as R from "ramda";
import { DataModel } from "../../../models";
import {
  localStorageSet,
  localStorageGet,
  localStorageRemove,
} from "../../../Services/LocalStorageService";
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

  console.log({ rivers, screenId, plugin });
  return plugin || null;
}

export function prepareData(general, rivers) {
  let data: Array<DataModel> = [];
  for (let index = 1; index <= 5; index++) {
    const screenId = general[`screen_selector_${index}`];
    const canBeSkiped = general[`can_be_skiped_screen_${index}`];
    const dataModel = dataModelFromScreenData(screenId, canBeSkiped, rivers);
    if (dataModel) {
      data.push(dataModel);
    }
  }
  return data;
}

function dataModelFromScreenData(
  screenId?: string,
  canBeSkiped: boolean = true,
  rivers?: any
): DataModel {
  if (R.not(R.isNil(screenId)) && R.not(R.isEmpty(screenId))) {
    const Screen: any = pluginByScreenId({
      rivers,
      screenId: screenId,
    });

    return { screenId, canBeSkiped, Screen };
  }
  return null;
}
//TODO: Remove it or add try catch handlers
export async function updatePresentedInfo() {
  return await localStorageSet();
}

export async function removePresentedInfo() {
  await localStorageRemove();
}

export async function screenShouldBePresented(): Promise<boolean> {
  return (await localStorageGet()) === false;
}
