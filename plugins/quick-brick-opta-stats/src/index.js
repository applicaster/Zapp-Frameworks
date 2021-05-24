import * as React from "react";
import { NativeModules } from "react-native";

import { createLogger } from "./logger";
import { DEFAULT } from "./utils";
import { styles } from "./styles";

import {requireNativeComponent} from 'react-native';


const OptaStatsContainer = requireNativeComponent('OptaStatsContainer');

type Props = {
  screenData: {
    general: any,
  },
};

const logger = createLogger();

useUrlSchemeHandler = async ({ query, url, onFinish }) => {
  const packageName = DEFAULT.packageName;
  const methodName = DEFAULT.methodName;
  const screenPackage = NativeModules?.[packageName];
  const method = screenPackage?.[methodName];

  if (!packageName) {
    logger.warn(`React package name is not set`);
    onFinish();
    return;
  }

  if (!methodName) {
    logger.warn(`React method name is not set`);
    onFinish();
    return;
  }

  if (!screenPackage) {
    logger.warn(`Package ${packageName} is not found`);
    onFinish();
    return;
  }

  if (!method) {
    logger.warn(`Method ${methodName} is not found in the package ${packageName}`);
    onFinish();
    return;
  };

  try {
    const res = await method({url});
    logger.info(`Received response from native method ${methodName}`, res);
    onFinish();
  } catch (error) {
    logger.error(`Method ${methodName} the package ${packageName} failed with error ${error}`);
    onFinish();
  }
};

export default StatScreens = ({ screenData }: Props) => {
  return <OptaStatsContainer style={styles.container}></OptaStatsContainer>
};

StatScreens.urlScheme = {
  host: "copa_stats",
  handler: useUrlSchemeHandler,
}
