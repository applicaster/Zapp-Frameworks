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

export default NativeScreen = () => {

  // these should come from the screen properties
  const packageName = "DidomiBridge";
  const methodName = "showPreferences";

  // todo: handle errors and fire exit action right away after showing some error message for the user

  const screenPackage = NativeModules[packageName];
  if(!screenPackage) {
    // todo: make it red
    // warn used that he did somethign wrong
    console.error("NativeScreen", `Package ${packageName} is not found`);
    return <Text style={styles.container}>`Package ${packageName} is not found`</Text>;
  }

  const method = screenPackage[methodName];
  if(!method) {
    // todo: make it red
    // warn used that he did somethign wrong
    console.error("NativeScreen", `Method ${methodName} is not found in the package ${packageName}`);
    return <Text style={styles.container}>`Method ${methodName} is not found in the package ${packageName}`</Text>;
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
