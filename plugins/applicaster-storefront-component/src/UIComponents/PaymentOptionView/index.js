import React from "react";
import { View, Text, Dimensions } from "react-native";
import PropTypes from "prop-types";
import { mapKeyToStyle } from "../../Utils/Customization";
import moment from "moment";
import {
  paymentOptionStyleKeys,
  styles,
  getBoxStyles,
  getButtonStyle,
} from "./StyleUtils";
import ActionButton from "../Buttons/ActionButton.js";

const paymentActions = {
  subscribe: "Subscribe for:",
  buy: "Buy for:",
};

function PaymentOptionView({
  screenStyles,
  paymentOptionItem,
  onPress,
  screenLocalizations,
}) {
  const isLandscape = () => {
    const { width, height } = Dimensions.get("window");
    return width >= height;
  };

  const {
    payment_option_button_corner_radius: radius = 50,
    payment_option_button_background: backgroundColor = "",
  } = screenStyles;

  const {
    title,
    description,
    price,
    productType,
    purchased,
    expiresAt,
  } = paymentOptionItem;
  const [
    titleStyle,
    descriptionStyle,
    labelStyle,
  ] = paymentOptionStyleKeys.map((key) => mapKeyToStyle(key, screenStyles));

  const actionForLabel =
    productType === "subscription"
      ? screenLocalizations?.payment_option_action_text_type_subscribe ||
        paymentActions.subscribe
      : screenLocalizations?.payment_option_action_text_type_buy ||
        paymentActions.buy;

  const buttonStyle = getButtonStyle(radius, backgroundColor);

  const label = `${actionForLabel} ${price}`.toUpperCase();
  function renderPaymmentAction() {
    return purchased ? (
      <>
        <Text style={titleStyle} numberOfLines={1} ellipsizeMode="tail">
          {screenLocalizations?.purchased_message}
        </Text>
        {expiresAt && (
          <Text style={description} numberOfLines={1} ellipsizeMode="tail">
            {`${
              screenLocalizations?.subscription_expiration_date_message
            } ${moment
              .unix(expiresAt)
              .format(
                screenLocalizations?.subscription_expiration_data_date_format
              )}`}
          </Text>
        )}
      </>
    ) : (
      <ActionButton
        labelStyle={labelStyle}
        buttonStyle={buttonStyle}
        title={label}
        onPress={onPress}
      />
    );
  }
  return (
    <View style={getBoxStyles(screenStyles, isLandscape)}>
      <Text style={titleStyle} numberOfLines={1} ellipsizeMode="tail">
        {title}
      </Text>
      <Text
        style={[descriptionStyle, styles.description]}
        numberOfLines={2}
        ellipsizeMode="tail"
      >
        {description}
      </Text>
      {renderPaymmentAction()}
    </View>
  );
}

PaymentOptionView.propTypes = {
  screenStyles: PropTypes.objectOf(PropTypes.any),
  paymentOptionItem: PropTypes.shape({
    title: PropTypes.string,
    description: PropTypes.string,
    price: PropTypes.string,
    productType: PropTypes.string,
  }),
  onPress: PropTypes.func,
};

PaymentOptionView.defaultProps = {
  screenStyles: {},
  paymentOptionItem: {},
};

export default PaymentOptionView;
