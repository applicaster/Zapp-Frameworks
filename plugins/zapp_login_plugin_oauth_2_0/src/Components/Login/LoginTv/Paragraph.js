import React from "react";
import { Text, View, StyleSheet } from "react-native";
import PropTypes from "prop-types";

import colors from "../../../colors";

const localStyles = StyleSheet.create({
  text: {
    fontSize: 24,
    lineHeight: 32,
    color: colors.grayLight,
    fontWeight: "normal",
  },
});

const Paragraph = ({ styles, label }) => {
  const textStyles = React.useMemo(() => [localStyles.text, styles], []);

  return (
    <View>
      <Text style={textStyles}>{label}</Text>
    </View>
  );
};

Paragraph.propTypes = {
  label: PropTypes.string,
  styles: PropTypes.object,
};

Paragraph.defaultProps = {
  label: "",
  styles: {},
};

export default Paragraph;
