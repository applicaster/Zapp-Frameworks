import React from "react";
import { View, Image, TouchableOpacity, StyleSheet } from "react-native";

const styles = StyleSheet.create({
  navbar: {
    width: "100%",
    height: 60,
    padding: 10,
    marginTop: 10,
    marginBottom: 40,
  },
  btnContainer: {
    position: "absolute",
    top: 10,
    left: 20,
  },
  closeBtn: {
    width: 45,
    height: 45,
  },
  logo: {
    alignSelf: "center",
    justifyContent: "center",
    width: 200,
    height: 44,
  },
});

export default function NavbarComponent({ buttonUrl, logoUrl, buttonAction }) {
  return (
    <View style={styles.navbar}>
      <Image style={styles.logo} source={{ uri: logoUrl }} />
      <TouchableOpacity
        onPress={() => buttonAction({ success: false })}
        style={styles.btnContainer}
      >
        <Image style={styles.closeBtn} source={{ uri: buttonUrl }} />
      </TouchableOpacity>
    </View>
  );
}
