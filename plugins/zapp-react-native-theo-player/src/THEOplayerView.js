import React from "react";
import { requireNativeComponent, View, StyleSheet } from "react-native";
import { useDimensions } from "@applicaster/zapp-react-native-utils/reactHooks";

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
  const window = useDimensions("window");

  return (
    <View style={styles.container}>
      <THEOplayerViewNative
        {...props}
        ref={ref}
        style={{ ...styles.player, width: window?.width }}
      />
    </View>
  );
});

export default THEOplayerView;
