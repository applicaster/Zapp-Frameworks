import React from "react";
import { StyleSheet } from "react-native";
import Label from "../../../../Label";
import { mapKeyToStyle } from "../../../../../../Utils/Customization";
import PropTypes from "prop-types";

const styles = StyleSheet.create({
  container: {
    marginTop: 45,
  },
  text: {
    alignSelf: "center",
    textAlign: "center",
  },
});

const FeeTitle = (props) => {
  const { paymentOptionItem, screenStyles } = props;
  const { title } = paymentOptionItem;

  const feeTitle = title.toUpperCase();

  const titleStyles = React.useMemo(
    () => mapKeyToStyle("payment_option_title_text", screenStyles),
    [screenStyles]
  );
  styles.text = React.useMemo(() => [styles.text, titleStyles], []);

  return <Label styles={styles} title={feeTitle} />;
};

FeeTitle.propTypes = {
  paymentOptionItem: PropTypes.object,
  screenStyles: PropTypes.object,
};

FeeTitle.defaultProps = {
  paymentOptionItem: {},
  screenStyles: {},
};

export default FeeTitle;
