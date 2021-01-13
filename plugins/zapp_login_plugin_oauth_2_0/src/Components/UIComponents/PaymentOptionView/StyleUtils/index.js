import { StyleSheet } from "react-native";

const paymentOptionStyleKeys = [
  "payment_option_title",
  "payment_option_description",
  "payment_option_button",
];

function getBoxStyles(screenStyles, isLandscape) {
  const borderRadius = Number(screenStyles?.payment_option_corner_radius);
  const backgroundColor = screenStyles?.payment_option_background;

  return {
    backgroundColor,
    minHeight: 170,
    width: isLandscape() ? 370 : "100%",
    margin: 10,
    padding: 20,
    alignItems: "center",
    justifyContent: "center",
    borderRadius,
  };
}

function getButtonStyle(radius, backgroundColor) {
  return {
    backgroundColor,
    borderRadius: Number(radius),
    width: 230,
    height: 40,
  };
}

const styles = StyleSheet.create({
  description: {
    marginVertical: 20,
    textAlign: "center",
  },
});

export { paymentOptionStyleKeys, styles, getBoxStyles, getButtonStyle };
