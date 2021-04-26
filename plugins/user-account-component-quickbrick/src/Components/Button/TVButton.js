import React from 'react';
import {
  Text,
  ImageBackground,
  Platform
} from 'react-native';
import { Focusable } from '@applicaster/zapp-react-native-ui-components/Components/Focusable';
import { FocusableGroup } from '@applicaster/zapp-react-native-ui-components/Components/FocusableGroup';


export default function TVButton(
  {
    label = '',
    onPress,
    backgroundColor = '',
    buttonStyle = {},
    textStyle = {},
    backgroundButtonUri = '',
    backgroundButtonUriActive = ''
  }
) {
  const id = 'tv-button';
  const groupId = `group-${id}`;
  const customStyle = Platform.OS === 'web' ? { ...buttonStyle, backgroundColor } : buttonStyle;

  return (
    <FocusableGroup id={groupId}>
      <Focusable id={id} onPress={onPress} groupId={groupId} preferredFocus="true">
        {
          (focused) => {
            return (
              <ImageBackground
                source={{ uri: focused ? backgroundButtonUriActive : backgroundButtonUri }}
                style={[customStyle, { opacity: focused ? 1 : 0.9 }]}
              >
                <Text
                  style={focused ? { ...textStyle, color: '#5F5F5F' } : textStyle}
                  numberOfLines={2}
                  ellipsizeMode="tail"
                >
                  {label}
                </Text>
              </ImageBackground>
            );
          }
        }
      </Focusable>
    </FocusableGroup>
  );
}
