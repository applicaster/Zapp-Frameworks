import React from "react";
import PropTypes from "prop-types";
import { Text, TouchableOpacity } from "react-native";
import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";

const BackButton = ({ onPress, disabled, screenStyles, title }) => {
  const containerStyle = {
    alignSelf: "flex-start",
    marginLeft: 35,
    marginTop: 20,
    zIndex: 100,
    position: "absolute",
  };

  const TextStyle = {
    fontFamily: platformSelect({
      ios: screenStyles?.back_button_font_ios,
      android: screenStyles?.back_button_font_android,
    }),
    fontSize: screenStyles?.back_button_font_size,
    color: screenStyles?.back_button_font_color,
  };

  return disabled === true ? null : (
    <TouchableOpacity style={containerStyle} onPress={onPress}>
      <Text style={TextStyle}>{title}</Text>
    </TouchableOpacity>
  );
};

BackButton.propTypes = {
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

BackButton.defaultProps = {
  title: 'Back',
  screenStyles: {}
};

export default BackButton;
