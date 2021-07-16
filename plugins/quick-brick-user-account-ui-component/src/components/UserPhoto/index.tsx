import React from "react";
import PropTypes from "prop-types";
import { StyleSheet, Image } from "react-native";

const styles = StyleSheet.create({
  image: { width: 55, height: 55, marginBottom: 23, marginTop: 31 },
});

export const UserPhoto = ({ imageSrc }) => (
  <Image style={styles.image} source={{ uri: imageSrc }} />
);

UserPhoto.propTypes = { imageSrc: PropTypes.string };
