import React from "react";
import PropTypes from "prop-types";
import { StyleSheet, Image } from "react-native";

const styles = StyleSheet.create({ image: { width: 350, height: 100 } });

const ClientLogo = ({ imageSrc }) => (
  <Image style={styles.image} source={{ uri: imageSrc }} />
);

ClientLogo.propTypes = { imageSrc: PropTypes.string };

export default ClientLogo;
