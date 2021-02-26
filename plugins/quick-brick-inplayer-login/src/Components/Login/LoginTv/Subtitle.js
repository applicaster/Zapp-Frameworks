import React from "react";
import { Text, View, StyleSheet } from "react-native";
import PropTypes from "prop-types";

import colors from "../../../colors";

const localStyles = StyleSheet.create({
  text: {
    fontSize: 32,
    color: colors.grayLighter,
    fontWeight: "normal",
  },
});

const Subtitle = ({ label, styles }) => {
  const textStyles = React.useMemo(() => [localStyles.text, styles], []);

  return (
    <View style={localStyles.container}>
      <Text style={textStyles}>{label}</Text>
    </View>
  );
};

Subtitle.propTypes = {
  label: PropTypes.string,
  styles: PropTypes.object,
};

Subtitle.defaultProps = {
  label: "Simple and Secure User Sign-up, Sign-in and Access Control.",
  styles: {},
};

export default Subtitle;
