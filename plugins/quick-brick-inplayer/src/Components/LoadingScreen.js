import React from "react";
import {
  ActivityIndicator,
  StyleSheet,
  SafeAreaView,
  Dimensions,
} from "react-native";

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
    height: Dimensions.get("window").height,
    width: Dimensions.get("window").width,
    position: "absolute",
    backgroundColor: "rgba(0,0,0,0.5)",
  },
});

const LoadingScreen = () => {
  return (
    <SafeAreaView style={styles.container}>
      <ActivityIndicator color={"white"} size={"large"} />
    </SafeAreaView>
  );
};

export default LoadingScreen;
