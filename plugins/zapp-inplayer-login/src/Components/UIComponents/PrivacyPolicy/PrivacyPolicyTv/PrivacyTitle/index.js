import React from "react";
import { StyleSheet } from "react-native";
import Label from "../../../Label";
import { mapKeyToStyle } from "../../../../../Utils/Customization";
import PropTypes from "prop-types";

const styles = StyleSheet.create({
  container: {
    marginTop: 66,
  },
  text: {
    alignSelf: "center",
    textAlign: "center",
  },
});

const PrivacyTitle = ({ screenStyles, title }) => {
  const titleStyles = React.useMemo(
    () => mapKeyToStyle("privacy_main_title_text", screenStyles),
    [screenStyles]
  );
  styles.text = React.useMemo(() => [styles.text, titleStyles], []);

  return <Label styles={styles} title={title} />;
};

PrivacyTitle.propTypes = {
  screenStyles: PropTypes.object,
  title: PropTypes.string,
};

PrivacyTitle.defaultProps = {
  screenStyles: {},
};

export default PrivacyTitle;
