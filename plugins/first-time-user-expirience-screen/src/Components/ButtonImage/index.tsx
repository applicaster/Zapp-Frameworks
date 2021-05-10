import React from "react";
import PropTypes from "prop-types";
import { Image } from "react-native";

const ButtonImage = ({ imageSrc, style }) => (
  <Image style={{ width: 40, height: 40 }} source={{ uri: imageSrc }} />
);

ButtonImage.propTypes = { imageSrc: PropTypes.string };

export default ButtonImage;
