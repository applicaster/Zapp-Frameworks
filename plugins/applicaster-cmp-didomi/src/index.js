import React from "react";
import {
  StyleSheet,
  Dimensions,
  View,
} from "react-native";

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
    height: Dimensions.get("window").height,
    width: Dimensions.get("window").width,
    backgroundColor: "rgba(0,0,0,0.5)",
  },
});

const NativeScreen = () => {
  return (
    <View style={styles.container}>
    </View>
  );
};

export default {
  isFlowBlocker: () => true,
  presentFullScreen: true,
  Component: NativeScreen,
};
