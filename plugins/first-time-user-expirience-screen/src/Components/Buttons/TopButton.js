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
  screenStyles: PropTypes.shape({
    back_button_font_ios: PropTypes.string,
    back_button_font_android: PropTypes.string,
    back_button_font_size: PropTypes.number,
    back_button_font_color: PropTypes.string,
  }),
};

TopButton.defaultProps = {
  title: "Back",
  screenStyles: {},
};

export default TopButton;
