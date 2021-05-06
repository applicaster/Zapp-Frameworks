import React from "react";
import PropTypes from "prop-types";
import { Image } from "react-native";

const ButtonImage = ({ imageSrc, style }) => (
  <Image style={{ width: 44, height: 44 }} source={{ uri: imageSrc }} />
);

ButtonImage.propTypes = { imageSrc: PropTypes.string };

export default ButtonImage;
