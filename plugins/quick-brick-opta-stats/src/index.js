import * as React from "react";
import { NativeModules } from "react-native";

import { createLogger } from "./logger";
import { DEFAULT } from "./utils";
import { styles } from "./styles";

import {requireNativeComponent} from 'react-native';


const OptaStatsContainer = requireNativeComponent('OptaStatsContainer');

const logger = createLogger();

useUrlSchemeHandler = async ({ query, url, onFinish }) => {
  const packageName = DEFAULT.packageName;
  const methodName = DEFAULT.methodName;
  const screenPackage = NativeModules?.[packageName];
  const method = screenPackage?.[methodName];

  const complete = () => {
    onFinish((done) => {
      done();
    });
  }

  if (!packageName) {
    logger.error(`React package name is not set`);
    complete();
    return;
  }

  if (!methodName) {
    logger.error(`React method name is not set`);
    complete();
    return;
  }

  if (!screenPackage) {
    logger.error(`Package ${packageName} is not found`);
    complete();
    return;
  }

  if (!method) {
    logger.error(`Method ${methodName} is not found in the package ${packageName}`);
    complete();
    return;
  };

  try {
    const res = await method({url});
    logger.info(`Received response from native method ${methodName}`, res);
  } catch (error) {
    logger.error(`Method ${methodName} the package ${packageName} failed with error ${error}`);
  }
  complete();
};

export default StatScreens = ({}) => {
  return <OptaStatsContainer style={styles.container}></OptaStatsContainer>
};

StatScreens.urlScheme = {
  host: "copa_stats",
  handler: useUrlSchemeHandler,
}
