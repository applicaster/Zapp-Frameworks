import React from "react";
import { Text, View, StyleSheet } from "react-native";
import PropTypes from "prop-types";

import colors from "../../../colors";

const localStyles = StyleSheet.create({
  container: {
    marginBottom: 71,
  },
  text: {
    fontSize: 60,
    color: colors.white,
    fontWeight: "bold",
  },
});

console.disableYellowBox = true;

const Title = ({ label, styles }) => {
  const textStyles = React.useMemo(() => [localStyles.text, styles], []);

  return (
    <View style={localStyles.container}>
      <Text style={textStyles}>{label}</Text>
    </View>
  );
};

Title.propTypes = {
  label: PropTypes.string,
  styles: PropTypes.object,
};

Title.defaultProps = {
  label: "Login to Your Account",
  styles: {},
};

export default Title;
