import React from "react";
import PropTypes from "prop-types";
import { Image } from "react-native";

const ButtonImage = ({ imageSrc, style }) => (
  <Image style={style} source={{ uri: imageSrc }} />
);

ButtonImage.propTypes = { imageSrc: PropTypes.string, style: {} };

export default ButtonImage;
