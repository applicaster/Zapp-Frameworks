import React from "react";
import { StyleSheet } from "react-native";
import Label from "../../../Label";
import { mapKeyToStyle } from "../../../../../Utils/Customization";
import PropTypes from "prop-types";

const styles = StyleSheet.create({
  container: {
    marginLeft: 100,
    marginRight: 100,
  },
  text: {
    alignSelf: "center",
    textAlign: "justify",
  },
});

const PrivacyDescription = ({ screenStyles, text }) => {
  const descriptionStyles = React.useMemo(
    () => mapKeyToStyle("privacy_text", screenStyles),
    [screenStyles]
  );
  styles.text = React.useMemo(() => [styles.text, descriptionStyles], []);

  const title = (text && text.replace(/\\n/g, "\n")) || "";
  return <Label styles={styles} title={title} />;
};

PrivacyDescription.propTypes = {
  screenStyles: PropTypes.object,
  text: PropTypes.string,
};

PrivacyDescription.defaultProps = {
  screenStyles: {},
};

export default PrivacyDescription;
