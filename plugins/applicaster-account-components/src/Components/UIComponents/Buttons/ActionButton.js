import React from "react";
import * as R from "ramda";
import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";
import { View, Text, TouchableOpacity } from "react-native";

const actionButtonContainerStyle = (screenStyles, customStyle) => {
  const defaultStyle = {
    height: 40,
    width: 230,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: screenStyles?.action_button_background_color || "#F1AD12",
    borderRadius: 50,
    alignSelf: "center",
  };

  return customStyle
    ? R.mergeDeepLeft(customStyle, defaultStyle)
    : defaultStyle;
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
  } = props;

  const textStyle = labelStyle || actionButtonTextStyle(screenStyles);

  return (
    <TouchableOpacity onPress={onPress} style={{ paddingTop: paddingTop }}>
      <View style={actionButtonContainerStyle(screenStyles, buttonStyle)}>
        <Text style={textStyle}>{title}</Text>
      </View>
    </TouchableOpacity>
  );
};

export default ActionButton;
