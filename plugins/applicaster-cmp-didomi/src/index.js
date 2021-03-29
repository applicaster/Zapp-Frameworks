import React from "react";
import { StyleSheet, Dimensions, View } from "react-native";
import { NativeModules } from "react-native";
const Didomi = NativeModules?.DidomiBridge;
const showPreferences = Didomi?.showPreferences;
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
  React.useEffect(() => {
    (async () => {
      console.log("didomi", { Didomi, showPreferences });
      const res = await showPreferences();
      console.log("didomi res", { res });
    })();
  }, []);
  return <View style={styles.container}></View>;
};
