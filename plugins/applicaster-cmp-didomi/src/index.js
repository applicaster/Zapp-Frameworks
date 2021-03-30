import React from "react";
import { StyleSheet, Dimensions, Text, View } from "react-native";
import { NativeModules } from "react-native";

import { useNavigation } from "@applicaster/zapp-react-native-utils/reactHooks/navigation";

/**
 * Class to present any native screens over QB application
 */

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
    height: Dimensions.get("window").height,
    width: Dimensions.get("window").width,
    backgroundColor: "rgba(0,255,0,0.5)",
  },
});

const stylesError = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
    height: Dimensions.get("window").height,
    width: Dimensions.get("window").width,
    color: "white",
    backgroundColor: "rgba(255,0 ,0,0.5)",
  },
});

type Props = {
  screenData: {
    general: any,
  },
};

function renderError(message: string) {
    // warn used that he did somethign wrong
    console.error("NativeScreen", message);
    // todo: in release builds, do not show the error component, just perform the return action
    // and maybe show some generic non-scare message
    return <Text style={stylesError.container}>Can not open native screen: {message}</Text>;
}

export default NativeScreen = (props: Props) => {

  console.log("NativeScreen", "props", props);

  // these should come from the screen properties
  const packageName = props?.screenData?.general?.reactPackageName;

  if(!packageName) {
    // warn used that he did somethign wrong
    return renderError(`React package name is not set`);
  }

  const methodName = props?.screenData?.general?.reactMethodName;

  if(!methodName) {
    // warn used that he did somethign wrong
    return renderError(`React method name is not set`);
  }

  // todo: handle errors and fire exit action right away after showing some error message for the user

  const screenPackage = NativeModules[packageName];
  if(!screenPackage) {
    // warn used that he did somethign wrong
    return renderError(`Package ${packageName} is not found`);
  }

  const method = screenPackage[methodName];
  if(!method) {
    // warn used that he did somethign wrong
    return renderError(`Method ${methodName} is not found in the package ${packageName}`);
  }

  var navigator = useNavigation();

  React.useEffect(() => {
    (async () => {
      // todo: add params
      const res = await method();
      // todo: obtain result as optional object
      // todo: handle errors and fire exit action right away after showing some error message for the user
      // todo: this exit action should be customizible: go back or go home/other screen
      if(navigator.canGoBack()) {
        navigator.goBack();
      } else {
        // else log a warning, since it gives bad UX
        console.warn("Can't bo back")
        navigator.goHome();
      }
    })();
  }, []);
  return <View style={styles.container}></View>;
};
