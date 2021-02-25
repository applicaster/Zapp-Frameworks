import React from "react";
import { StyleSheet } from "react-native";
import Label from "../../../../Label";
import { mapKeyToStyle } from "../../../../../../Utils/Customization";
import PropTypes from "prop-types";

const styles = StyleSheet.create({
  container: {},
  text: {
    alignSelf: "center",
    textAlign: "center",
  },
});

const FeeType = (props) => {
  const { paymentOptionItem, screenStyles, screenLocalizations } = props;

  const { productType } = paymentOptionItem;
  const {
    payment_option_action_text_type_buy = "Buy",
    payment_option_action_text_type_subscribe = "Subscribe",
  } = screenLocalizations;
  const title =
    productType === "subscription"
      ? payment_option_action_text_type_subscribe
      : payment_option_action_text_type_buy;
  const titleStyles = React.useMemo(
    () => mapKeyToStyle("payment_option_action_text", screenStyles),
    [screenStyles]
  );
  styles.text = React.useMemo(() => [styles.text, titleStyles], []);

  return <Label styles={styles} title={title.toUpperCase()} />;
};

FeeType.propTypes = {
  paymentOptionItem: PropTypes.object,
  screenStyles: PropTypes.object,
  screenLocalizations: PropTypes.object,
};

FeeType.defaultProps = {
  paymentOptionItem: {},
  screenStyles: {},
  screenLocalizations: {},
};

export default FeeType;
