import React from "react";
import { Text, TouchableOpacity } from "react-native";
import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";

const Button = ({
  onPress,
  hidden,
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
  }

  return (
    <TouchableOpacity style={touchStyles} onPress={onPress}>
      {!hidden && <Text style={textStyle}>{title}</Text>}
    </TouchableOpacity>
  );
};

export default Button;
