import React from "react";
import { StyleSheet } from "react-native";
import Label from "../../../../Label";
import { mapKeyToStyle } from "../../../../../../Utils/Customization";
import PropTypes from "prop-types";

const styles = StyleSheet.create({
  container: {
    marginTop: 25,
  },
  text: {
    alignSelf: "center",
    textAlign: "center",
  },
});

const FeePrice = (props) => {
  const { paymentOptionItem, screenStyles } = props;
  const { price } = paymentOptionItem;

  const title = price.toUpperCase();

  const titleStyles = React.useMemo(
    () => mapKeyToStyle("payment_option_fee_text", screenStyles),
    [screenStyles]
  );
  styles.text = React.useMemo(() => [styles.text, titleStyles], []);

  return <Label styles={styles} title={title} />;
};

FeePrice.propTypes = {
  paymentOptionItem: PropTypes.object,
  screenStyles: PropTypes.object,
};

FeePrice.defaultProps = {
  paymentOptionItem: {},
  screenStyles: {},
};

export default FeePrice;
