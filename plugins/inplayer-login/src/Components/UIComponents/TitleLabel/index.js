import React from "react";
import PropTypes from "prop-types";
import { Text } from "react-native";
import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";

const TitleLabel = ({ screenStyles, title }) => {
  const style = {
    fontFamily: platformSelect({
      ios: screenStyles?.title_font_ios,
      android: screenStyles?.title_font_android,
    }),
    fontSize: screenStyles?.title_font_size,
    color: screenStyles?.title_font_color,
    marginTop: 100,
    marginBottom: 80,
    alignSelf: "center",
    textAlign: "center",
  };

  return <Text style={style}>{title}</Text>;
};

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
