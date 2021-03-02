import React from "react";
import { StyleSheet } from "react-native";
import Label from "../../../../Label";
import { mapKeyToStyle } from "../../../../../../Utils/Customization";
import PropTypes from "prop-types";

const styles = StyleSheet.create({
  container: {
    marginTop: 20,
  },
  text: {
    alignSelf: "center",
    textAlign: "center",
  },
});

const FeeDescription = (props) => {
  const { paymentOptionItem, screenStyles } = props;
  const { description } = paymentOptionItem;

  const title = description;

  const titleStyles = React.useMemo(
    () => mapKeyToStyle("payment_option_description_text", screenStyles),
    [screenStyles]
  );
  styles.text = React.useMemo(() => [styles.text, titleStyles], []);

  return <Label styles={styles} title={title} />;
};

FeeDescription.propTypes = {
  paymentOptionItem: PropTypes.object,
  screenStyles: PropTypes.object,
};

FeeDescription.defaultProps = {
  paymentOptionItem: {},
  screenStyles: {},
};

export default FeeDescription;
