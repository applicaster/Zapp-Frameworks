import * as React from "react";
import { Text, View, TouchableOpacity } from "react-native";
import { NativeModules } from "react-native";

import { useNavigation } from "@applicaster/zapp-react-native-utils/reactHooks/navigation";
import { createLogger, addContext } from "./logger";
import { DEFAULT, releaseBuild } from "./utils";
import { styles, stylesError } from "./styles";


import {requireNativeComponent} from 'react-native';

const OptaStatsContainer = requireNativeComponent('OptaStatsContainer');

/**
 * Class to present any native screens over QB application
 */

type Props = {
  screenData: {
    general: any,
  },
};

const logger = createLogger();

function renderError(message: string, onDismiss: () => void) {
  logger.warn(message);

  return !releaseBuild ? (
    <View style={stylesError.container}>
      <Text style={stylesError.alert}>⚠️</Text>
      <Text style={stylesError.message}>Could not open native screen:</Text>
      <Text style={stylesError.errorMessage}>{message}</Text>
      <TouchableOpacity style={stylesError.button} onPress={onDismiss}>
        <Text style={stylesError.buttonText}>Dismiss</Text>
      </TouchableOpacity>
    </View>
  ) : (
    <View style={stylesError.container} onLayout={onDismiss}>
      <Text style={stylesError.message}>Could not open native screen</Text>
    </View>
  );
}

export default NativeScreen = ({ screenData }: Props) => {
  const navigator = useNavigation();
  const generalData = screenData?.general;
  const packageName = generalData?.package_name || DEFAULT.packageName;
  const methodName = generalData?.method_name || DEFAULT.methodName;
  const screenPackage = NativeModules?.[packageName];
  const method = screenPackage?.[methodName];

  const { url } = screenData

  if(!url) {
    // show home screen (url is always null for now)
    return <OptaStatsContainer style={styles.container}></OptaStatsContainer>
  }

  const onDismiss = () => {
    
    // todo: this exit action should be customizible: go back or go home/other screen
    // manifest already has fields set up for this behavior
    if (navigator.canGoBack()) {
      logger.info("Dismissed native screen, going back");
      navigator.goBack();
    } else {
      logger.warn("Dismissed native screen, can't go back, trying to go home");
      navigator.goHome();
    }
  };

  if (!packageName) {
    // warn used that he did somethign wrong
    return renderError(`React package name is not set`, onDismiss);
  }

  if (!methodName) {
    // warn used that he did somethign wrong
    return renderError(`React method name is not set`, onDismiss);
  }

  // todo: handle errors and fire exit action right away after showing some error message for the user

  if (!screenPackage) {
    // warn used that he did somethign wrong
    return renderError(`Package ${packageName} is not found`, onDismiss);
  }

  if (!method) {
    // warn used that he did somethign wrong
    return renderError(
      `Method ${methodName} is not found in the package ${packageName}`,
      onDismiss
    );
  }

  React.useEffect(() => {
    (async () => {
      addContext({
        manifestData: DEFAULT,
        screenId: screenData.id,
        screenName: screenData.name,
      });
      // todo: add params

      try {
        const res = await method({url});
        logger.info(`Received response from native method ${methodName}`, res);
        onDismiss();
      } catch (error) {
        renderError(error);
      }
      // todo: obtain result as optional object
      // todo: handle errors and fire exit action right away after showing some error message for the user
    })();

    return () => {
      logger.info("Unmounted native screen");
      onDismiss();
    };
  }, []);
  return <View style={styles.container}></View>;
};
