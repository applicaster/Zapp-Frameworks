import React from "react";
import { Text, ImageBackground, StyleSheet } from "react-native";
import { Focusable } from "@applicaster/zapp-react-native-ui-components/Components/Focusable";

export default function Button({
  label = "",
  onPress,
  preferredFocus,
  buttonRef,
  nextFocusDown,
  nextFocusUp,
  groupId,
  textStyle = {},
  backgroundColor = "",
  backgroundButtonUri = "",
  backgroundButtonUriActive = "",
}) {
  const buttonStyle = { ...styles.input, backgroundColor };
    
  return (
    <Focusable
      id={`tv-button-${label}`}
      onPress={onPress}
      groupId={groupId}
      preferredFocus={preferredFocus}
      ref={buttonRef}
      nextFocusDown={nextFocusDown}
      nextFocusUp={nextFocusUp}
    >
      {(focused) => {
        return (
          <ImageBackground
            source={{
              uri: focused ? backgroundButtonUriActive : backgroundButtonUri,
            }}
            style={[buttonStyle, styles.opacity(focused)]}
          >
            <Text
              style={focused ? styles.textStyle(textStyle) : textStyle}
              numberOfLines={2}
              ellipsizeMode="tail"
            >
              {label}
            </Text>
          </ImageBackground>
        );
      }}
    </Focusable>
  );
}

const COLOR = "#5F5F5F";

const styles = StyleSheet.create({
  input: {
    width: 600,
    height: 90,
    justifyContent: "center",
    alignItems: "center",
    marginBottom: 10,
  },
  opacity: (focused) => ({ opacity: focused ? 1 : 0.9 }),
  textStyle: (textStyle) => ({ ...textStyle, color: COLOR }),
});
