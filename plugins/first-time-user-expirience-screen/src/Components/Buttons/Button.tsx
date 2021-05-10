import React from "react";
import { Text, TouchableOpacity } from "react-native";

const Button = ({
  onPress,
  hidden = false,
  disabled = false,
  screenStyles,
  title,
  styles,
  textStyle,
  stylesDisabled,
  textStyleDisabled,
}) => {
  let containedStyles = disabled ? stylesDisabled : styles;
  let textStyles = disabled ? textStyleDisabled : textStyle;
  if (hidden) {
    containedStyles = {
      ...containedStyles,
      backgroundColor: "transparent",
      borderColor: "transparent",
    };
  }
  return (
    <TouchableOpacity
      disabled={hidden || disabled}
      style={containedStyles}
      onPress={onPress}
    >
      {!hidden && <Text style={textStyles}>{title}</Text>}
    </TouchableOpacity>
  );
};

export default Button;
