import { StyleSheet, Text, View } from "react-native";
import PropTypes from "prop-types";
import { mapKeyToStyle, withEndSpace } from "../../../Utils/Customization";
import OpenURLButton from "../Buttons/OpenUrlButton";
import React from "react";

const termsOFUseStyleKeys = ["terms_of_use_instructions", "terms_of_use_link"];

export default function Footer({ screenStyles, screenLocalizations }) {
  const [
    termsOfUseStyle,
    termsOfUseLinkStyle,
  ] = termsOFUseStyleKeys.map((key) => mapKeyToStyle(key, screenStyles));

  return (
    <View style={styles.footer}>
      <Text
        style={[termsOfUseStyle, { textAlign: "center" }]}
        numberOfLines={3}
        ellipsizeMode="tail"
      >
        {withEndSpace(screenLocalizations.terms_of_use_instructions_text)}
        <OpenURLButton linkStyle={termsOfUseLinkStyle} url={screenLocalizations.terms_of_use_link}>
          {screenLocalizations.terms_of_use_link_text}
        </OpenURLButton>
      </Text>
    </View>
  );
}

Footer.propTypes = {
  screenStyles: PropTypes.object,
  screenLocalizations: PropTypes.shape({
    terms_of_use_instructions_text: PropTypes.string,
    terms_of_use_link: PropTypes.string,
    terms_of_use_link_text: PropTypes.string,
  }),
};

Footer.defaultProps = {
  screenStyles: {},
  screenLocalizations: {},
};

const styles = StyleSheet.create({
  footer: {
    padding: 25,
    minHeight: 80,
    maxHeight: 120,
  },
});
