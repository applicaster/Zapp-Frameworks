import React from "react";
import { Text, TouchableOpacity } from "react-native";
import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";

const FloatingButton = ({
  screenStyles,
  screenLocalizations,
  onNext,
  onClose,
  isLastScreen = false,
  disabled = false,
}) => {
  const {
    back_button_text,
    next_button_text,
    close_button_text,
  } = screenLocalizations;

  const textStyle = {
    fontFamily: platformSelect({
      ios: screenStyles?.top_button_font_ios,
      android: screenStyles?.top_button_font_android,
    }),
    fontSize: screenStyles?.top_button_font_size,
    color: screenStyles?.top_button_font_color,
  };
  const buttonStyle = {
    right: 10,
    top: 50,
    padding: 5,
    position: "absolute",
    borderRadius: Number(screenStyles?.top_button_radius),
    borderColor: screenStyles?.top_button_border_color,
    borderWidth: screenStyles?.top_button_border_size,
    backgroundColor: screenStyles?.top_button_background_color,
  };

  return disabled === true ? null : (
    <TouchableOpacity
      style={buttonStyle}
      onPress={isLastScreen ? onClose : onNext}
    >
      <Text style={textStyle}>
        {isLastScreen ? close_button_text : next_button_text}
      </Text>
    </TouchableOpacity>
  );
};

export default FloatingButton;
