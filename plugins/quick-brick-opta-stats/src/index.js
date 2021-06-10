import * as React from "react";
import { NativeModules, View, ActivityIndicator } from "react-native";

import { createLogger } from "./logger";
import { DEFAULT } from "./utils";
import { styles } from "./styles";

import { requireNativeComponent } from "react-native";

import { useNavigation } from "@applicaster/zapp-react-native-utils/reactHooks/navigation";

const OptaStatsContainer = requireNativeComponent("OptaStatsContainer");

const logger = createLogger();
let renderedStats = null;
openScreen = async (url, complete) => {
  const packageName = DEFAULT.packageName;
  const methodName = DEFAULT.methodName;
  const screenPackage = NativeModules?.[packageName];
  const method = screenPackage?.[methodName];

  if (!packageName) {
    logger.error("React package name is not set");
    complete();
    return;
  }

  if (!methodName) {
    logger.error("React method name is not set");
    complete();
    return;
  }

  if (!screenPackage) {
    logger.error("Package ${packageName} is not found");
    complete();
    return;
  }

  if (!method) {
    logger.error(
      "Method ${methodName} is not found in the package ${packageName}"
    );
    complete();
    return;
  }

  try {
    const res = await method({ url });
    logger.info("Received response from native method ${methodName}", res);
  } catch (error) {
    logger.error(
      "Method ${methodName} the package ${packageName} failed with error ${error}"
    );
  }
  complete();
};

useUrlSchemeHandler = async ({ query, url, onFinish }) => {
  const complete = () => {
    onFinish((done) => {
      done();
    });
  };
  openScreen(url, complete);
};

export default StatScreens = (props: Any) => {
  const url = props?.screenData?.extensions?.url;
  const navigator = useNavigation();

  function renderLoading() {
    return (
      <View style={styles.loading}>
        <ActivityIndicator size="large" color="#00ff00" />
      </View>
    );
  }

  React.useEffect(() => {
    logger.info({ message: "Render for some reason", data: { url } });
    renderedStats = true;
    return () => (renderedStats = false);
  }, [url]);

  const renderUrl = React.useCallback(() => {
    // You have URL Screen
    logger.info({ message: "COPA url", data: { url } });
    const onDismiss = () => {
      if (navigator.canGoBack()) {
        logger.info("Dismissed native screen, going back");
        navigator.goBack();
      } else {
        logger.warn(
          "Dismissed native screen, can't go back, trying to go home"
        );
        navigator.goHome();
      }
    };

    setTimeout(() => {
      openScreen(url, onDismiss);
    }, 1);

    return renderLoading();
  }, [url]);

  function renderStats() {
    logger.info({ message: "Render stats screen", data: { url } });

    return <OptaStatsContainer style={styles.container}></OptaStatsContainer>;
  }

  return url && !renderedStats ? renderUrl() : renderStats();
};

StatScreens.urlScheme = {
  host: "copa_stats",
  handler: useUrlSchemeHandler,
};
