import React from "react";
import { ScrollView, StyleSheet, Text, View, Dimensions } from "react-native";
import PropTypes from "prop-types";
import PaymentOptionView from "../../../PaymentOptionView";
import { container } from "../../../../Styles";
import {
  mapKeyToStyle,
  withEndSpace,
} from "../../../../../Utils/Customization";

const storefrontStyleKeys = [
  "payment_screen_title",
  "restore_purchases_text",
  "restore_purchases_link",
];

export default function StoreFrontContainer(props) {
  const isLandscape = () => {
    const { width, height } = Dimensions.get('window');
    return width >= height;
  };

  const {
    dataSource,
    onPressPaymentOption,
    onPressRestore,
    screenStyles,
    screenLocalizations,
  } = props;

  const [
    paymentTitleStyle,
    restoreTextStyle,
    restoreLinkStyle,
  ] = storefrontStyleKeys.map((key) => mapKeyToStyle(key, screenStyles));

  return (
    <View style={[styles.container, { paddingHorizontal: 25, marginHorizontal: 25}]}>
      <Text style={paymentTitleStyle} numberOfLines={1} ellipsizeMode="tail">
        {screenLocalizations.payment_screen_title_text}
      </Text>
      <View style={styles.restoreContainer}>
        <Text
          style={[restoreTextStyle, { textAlign: "center" }]}
          numberOfLines={2}
          ellipsizeMode="tail"
        >
          {withEndSpace(screenLocalizations.restore_purchases_text)}
          <Text style={restoreLinkStyle} onPress={onPressRestore}>
            {screenLocalizations.restore_purchases_link}
          </Text>
        </Text>
      </View>
      <View style={{flex: 1}}>
        <ScrollView
          horizontal={isLandscape()}
          contentContainerStyle={styles.contentContainer}
          showsHorizontalScrollIndicator={false}
          showsVerticalScrollIndicator={false}
          fadingEdgeLength={10}
          decelerationRate="normal"
        >
          {dataSource.map((item, index) => (
            <PaymentOptionView
              screenStyles={screenStyles}
              paymentOptionItem={item}
              key={item.productIdentifier}
              onPress={() => onPressPaymentOption(index)}
            />
          ))}
        </ScrollView>
      </View>
    </View>
  );
}

StoreFrontContainer.propTypes = {
  dataSource: PropTypes.array,
  onPressPaymentOption: PropTypes.func,
  onPressRestore: PropTypes.func,
  screenStyles: PropTypes.object,
  screenLocalizations: PropTypes.shape({
    payment_screen_title_text: PropTypes.string,
    restore_purchases_text: PropTypes.string,
    restore_purchases_link: PropTypes.string,
  }),
};

StoreFrontContainer.defaultProps = {
  screenStyles: {},
  screenLocalizations: {},
};

const styles = StyleSheet.create({
  container,
  restoreContainer: {
    alignItems: "center",
    marginVertical: 20,
  },
  contentContainer: {
    justifyContent: "center",
    alignItems: "center",
    marginBottom: 40,
  }
});
