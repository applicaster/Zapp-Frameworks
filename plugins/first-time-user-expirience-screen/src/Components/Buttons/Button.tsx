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
  return hidden === true ? null : (
    <TouchableOpacity style={styles} onPress={onPress}>
      <Text style={textStyle}>{title}</Text>
    </TouchableOpacity>
  );
};

export default Button;
