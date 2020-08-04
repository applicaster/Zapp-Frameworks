import React from 'react';
import {
  Platform,
  TouchableOpacity,
  Text,
  ImageBackground
} from 'react-native';


export default function MobileButton(
  {
    label = '',
    onPress,
    buttonStyle = {},
    textStyle = {},
    backgroundButtonUri
  }
) {
  const formattedTitle = Platform.OS === 'android' ? label.toUpperCase() : label;
  return (
    <TouchableOpacity
      accessibilityRole="button"
      onPress={onPress}
    >
      <ImageBackground
        source={{ uri: backgroundButtonUri }}
        style={buttonStyle}
      >
        <Text style={textStyle}>
          {formattedTitle}
        </Text>
      </ImageBackground>
    </TouchableOpacity>
  );
}
