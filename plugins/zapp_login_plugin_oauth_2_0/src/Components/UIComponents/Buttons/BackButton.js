import React from "react";
import PropTypes from "prop-types";
import { Text, TouchableOpacity, StyleSheet } from "react-native";
import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";

const BackButton = ({ onPress, disabled, screenStyles, title }) => {
  const styles = getStyles(screenStyles);

  return disabled === true ? null : (
    <TouchableOpacity
      style={[styles.defaultContainer, screenStyles?.back_button_position === "bottom" && styles.bottomContainer]}
      onPress={onPress}
    >
      <Text style={styles.text}>{title}</Text>
    </TouchableOpacity>
  );
};

const getStyles = (screenStyles) => StyleSheet.create({
  defaultContainer: {
    alignSelf: "flex-start",
    marginLeft: 35,
    marginTop: 20,
    zIndex: 100,
    position: "absolute",
  },
  bottomContainer: {
    alignSelf: "center",
    marginLeft: 0,
    marginTop: 10,
    bottom: 65
  },
  text: {
    fontFamily: platformSelect({
      ios: screenStyles?.back_button_font_ios,
      android: screenStyles?.back_button_font_android,
    }),
    fontSize: screenStyles?.back_button_font_size,
    color: screenStyles?.back_button_font_color,
  }
});

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
