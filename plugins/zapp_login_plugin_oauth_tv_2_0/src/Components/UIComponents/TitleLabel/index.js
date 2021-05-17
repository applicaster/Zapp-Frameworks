import React from "react";
import PropTypes from "prop-types";
import { Text, StyleSheet, View } from "react-native";
import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";

const TitleLabel = ({ screenStyles, title, subtitle }) => {
  const styles = getStyles(screenStyles);

  return (
    <View style={styles.container}>
      <Text style={styles.title}>{title}</Text>
      {screenStyles?.subtitle && <Text style={styles.subtitle}>{subtitle}</Text>}
    </View>
  );
};

const getStyles = (screenStyles) => StyleSheet.create({
  container: {
    marginHorizontal: 40,
    marginTop: screenStyles?.client_logo_position === "top" ? 220 : 100,
    marginBottom: 80,
    alignSelf: "center",
  },
  title: {
    textAlign: "center",
    fontSize: screenStyles?.title_font_size,
    color: screenStyles?.title_font_color,
    fontFamily: platformSelect({
      ios: screenStyles?.title_font_ios,
      android: screenStyles?.title_font_android,
    }),
  },
  subtitle: {
    marginTop: 20,
    textAlign: "center",
    fontSize: screenStyles?.subtitle_font_size,
    color: screenStyles?.subtitle_font_color,
    fontFamily: platformSelect({
      ios: screenStyles?.subtitle_font_ios,
      android: screenStyles?.subtitle_font_android,
    }),
  }
});

TitleLabel.propTypes = {
  title: PropTypes.string,
  screenStyles: PropTypes.shape({
    title_font_ios: PropTypes.string,
    title_font_android: PropTypes.string,
    title_font_size: PropTypes.number,
    title_font_color: PropTypes.string,
  }),
};

TitleLabel.defaultProps = {
  screenStyles: {},
};

export default TitleLabel;
