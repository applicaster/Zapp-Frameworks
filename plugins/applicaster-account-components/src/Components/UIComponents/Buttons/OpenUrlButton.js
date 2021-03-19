import React, { useCallback } from "react";
import { Linking, Alert, Text } from "react-native";

const errorMessage = "Don't know how to open this URL:";

const OpenURLButton = ({ url, children, linkStyle }) => {
  const handlePress = useCallback(async () => {
    const supported = await Linking.canOpenURL(url);

    if (supported) {
      await Linking.openURL(url);
    } else {
      Alert.alert(`${errorMessage} ${url}`);
    }
  }, [url]);

  return (
    <Text style={linkStyle} onPress={handlePress}>
      {children}
    </Text>
  );
};

export default OpenURLButton;
