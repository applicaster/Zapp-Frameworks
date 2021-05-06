import React from "react";
import PropTypes from "prop-types";
import { Text, TouchableOpacity } from "react-native";
import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";

const TopButton = ({
  onPress,
  disabled,
  screenStyles,
  title,
  style,
  textStyle,
}) => {
  return disabled === true ? null : (
    <TouchableOpacity style={style} onPress={onPress}>
      <Text style={textStyle}>{title}</Text>
    </TouchableOpacity>
  );
};

TopButton.propTypes = {
  title: PropTypes.string,
  onPress: PropTypes.func,
  disabled: PropTypes.bool,
};

TopButton.defaultProps = {
  title: "",
  screenStyles: {},
};

export default TopButton;
