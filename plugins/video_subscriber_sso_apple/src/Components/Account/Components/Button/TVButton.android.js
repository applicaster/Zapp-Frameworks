/* eslint-disable arrow-body-style,react/jsx-props-no-spreading */
import React, { useRef } from "react";
import { Text, ImageBackground } from "react-native";
import { Focusable } from "@applicaster/zapp-react-native-ui-components/Components/Focusable";
import { useInitialFocus } from "@applicaster/zapp-react-native-utils/focusManager";

export default function TVButton({
  label = "",
  onPress,
  buttonStyle = {},
  textStyle = {},
  backgroundButtonUri = "",
  backgroundButtonUriActive = "",
  focus,
  parentFocus,
}) {
  const buttonRef = useRef(null);
  useInitialFocus(focus, buttonRef);

  return (
    <Focusable
      id="logout-btn"
      ref={buttonRef}
      onPress={onPress}
      {...{ ...parentFocus }}
    >
      {(focused) => {
        return (
          <ImageBackground
            source={{
              uri: focused ? backgroundButtonUriActive : backgroundButtonUri,
            }}
            style={buttonStyle}
          >
            <Text
              style={focused ? { ...textStyle, color: "#5F5F5F" } : textStyle}
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
