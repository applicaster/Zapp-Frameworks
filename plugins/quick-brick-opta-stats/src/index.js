import * as React from "react";

import { createLogger } from "./logger";
import { styles } from "./styles";

import { requireNativeComponent } from "react-native";

const OptaStatsContainer = requireNativeComponent("OptaStatsContainer");
const OptaTeamContainer = requireNativeComponent("OptaTeamContainer");

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
  };

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
    logger.error(
      `Method ${methodName} is not found in the package ${packageName}`
    );
    complete();
    return;
  }

  try {
    const res = await method({ url });
    logger.info(`Received response from native method ${methodName}`, res);
  } catch (error) {
    logger.error(
      `Method ${methodName} the package ${packageName} failed with error ${error}`
    );
  }
  complete();
};

export default StatScreens = (props) => {
  const teamId = props?.screenData?.extensions?.teamId;

  const renderTeam = () => {
    logger.info({ message: "Render COPA Team", data: { teamId } });

    return <OptaTeamContainer team={teamId} style={styles.container} />;
  };

  function renderStats() {
    logger.info({ message: "Render COPA stats" });

    return <OptaStatsContainer style={styles.container}></OptaStatsContainer>;
  }

  return teamId ? renderTeam() : renderStats();
};

StatScreens.urlScheme = {
  host: "copa_stats",
  handler: useUrlSchemeHandler,
};
