import React from "react";
import { Text, TouchableOpacity } from "react-native";
import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";

const Button = ({
  onPress,
  hidden = false,
  disabled = false,
  screenStyles,
  title,
  styles,
  textStyle,
}) => {
  let touchStyles = styles;
  if (hidden) {
    touchStyles = {
      ...touchStyles,
      backgroundColor: "transparent",
      borderColor: "transparent",
    };
  } else if (disabled) {
  }
  console.log({ hidden, disabled });
  return (
    <TouchableOpacity
      disabled={hidden || disabled}
      style={touchStyles}
      onPress={onPress}
    >
      {!hidden && !disabled && <Text style={textStyle}>{title}</Text>}
    </TouchableOpacity>
  );
};

export default Button;
