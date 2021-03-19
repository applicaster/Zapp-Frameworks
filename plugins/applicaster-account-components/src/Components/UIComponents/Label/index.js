import React from "react";
import { Text, View } from "react-native";
import PropTypes from "prop-types";

const Label = (props) => {
  const { styles, title } = props;

  return (
    <View style={styles.container}>
      <Text style={styles.text}>{title}</Text>
    </View>
  );
};

Label.propTypes = {
  title: PropTypes.string,
  styles: PropTypes.object,
};
export default Label;
