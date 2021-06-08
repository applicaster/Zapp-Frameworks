import React from "react";
import * as R from "ramda";
import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";
import { View, Text, TouchableOpacity } from "react-native";

const actionButtonContainerStyle = (screenStyles, customStyle, disabled) => {
  const defaultStyle = {
    height: 40,
    width: 230,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: screenStyles?.action_button_background_color || "#F1AD12",
    borderRadius: 50,
    alignSelf: "center",
  };
  const result = customStyle
    ? R.mergeDeepLeft(customStyle, defaultStyle)
    : defaultStyle;

  if (disabled) {
    return { ...result, backgroundColor: "darkgrey" };
  }
  return result;
};

const actionButtonTextStyle = (screenStyles) => {
  return {
    fontFamily: platformSelect({
      ios: screenStyles?.action_button_font_ios,
      android: screenStyles?.action_button_font_android,
    }),
    fontSize: screenStyles?.action_button_font_size,
    color: screenStyles?.action_button_font_color,
  };
};

const ActionButton = (props) => {
  const {
    screenStyles,
    labelStyle,
    buttonStyle,
    title,
    onPress,
    paddingTop = null,
    disabled,
  } = props;

  const textStyle = labelStyle || actionButtonTextStyle(screenStyles);
  const actionButtonContainerStyles = actionButtonContainerStyle(
    screenStyles,
    buttonStyle,
    disabled
  );
  return (
    <TouchableOpacity
      disabled={disabled}
      onPress={onPress}
      style={{ paddingTop: paddingTop }}
    >
      <View style={actionButtonContainerStyles}>
        <Text style={textStyle}>{title}</Text>
      </View>
    </TouchableOpacity>
  );
};

export default ActionButton;
