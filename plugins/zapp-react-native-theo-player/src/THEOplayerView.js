import React from "react";
import { requireNativeComponent, StyleSheet } from "react-native";
import { SafeAreaView, useSafeAreaFrame } from "react-native-safe-area-context";

const THEOplayerViewNative = requireNativeComponent(
  "THEOplayerView",
  THEOplayerView
);

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: "#000" },
  player: {
    width: "100%",
    height: "100%",
    padding: 0,
    margin: 0,
  },
});

const THEOplayerView = React.forwardRef((props, ref) => {
  const frame = useSafeAreaFrame();

  return (
    <SafeAreaView style={styles.container}>
      <THEOplayerViewNative
        {...props}
        ref={ref}
        style={{ ...styles.player, width: frame?.width }}
      />
    </SafeAreaView>
  );
});

export default THEOplayerView;
