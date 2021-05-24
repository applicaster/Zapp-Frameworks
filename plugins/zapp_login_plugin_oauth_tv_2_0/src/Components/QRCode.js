import React, { memo, useState, useEffect} from "react";
import makeQRCodeUri from 'yaqrcode'
import { View, Image } from "react-native";

function QRButton({ url }) {
  return (
    <View style={styles.container}>
    <Image
      style={styles.image}
      resizeMode="contain"
      source={{ uri: makeQRCodeUri(url, { size: 300 }) }}
    />
    </View>
  );
}

export default memo(QRButton)

const styles = {
  container: { backgroundColor: '#fff', padding: 15 },
  image: { width: 300, height: 300 }
}
