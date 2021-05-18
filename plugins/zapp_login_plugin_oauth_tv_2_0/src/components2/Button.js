import * as React from "react";
import { FocusableGroup } from "@applicaster/zapp-react-native-ui-components/Components/FocusableGroup";
import { Focusable } from "@applicaster/zapp-react-native-ui-components/Components/Focusable";
import { View, Text, Platform } from "react-native";

export default function Button(props) {
  const {
    id,
    label,
    groupId,
    onPress,
    preferredFocus,
    buttonRef,
    nextFocusLeft,
    nextFocusDown,
    nextFocusUp,
    style
  } = props;

  const renderButton = (focused, label) => {
    const buttonStyles = styles[focused ? "focused" : "default"];
    return (
      <View style={buttonStyles.button}>
        <Text style={buttonStyles.buttonText}>{label}</Text>
      </View>
    )
  };

  return (
    Platform.OS !== 'android'
      ? <FocusableGroup
        id={id}
        style={style}
        preferredFocus={preferredFocus}
        groupId={groupId}
      >
        <Focusable
          id={`oc-adobe-${label}`}
          groupId={id}
          onPress={onPress}
          preferredFocus={preferredFocus}
        >
          {focused => renderButton(focused, label)}
        </Focusable>
      </FocusableGroup>
      : <View style={style}>
        <Focusable
          ref={buttonRef}
          id={id}
          onPress={onPress}
          nextFocusLeft={nextFocusLeft}
          nextFocusDown={nextFocusDown}
          nextFocusUp={nextFocusUp}
        >
          {(focused) => renderButton(focused, label)}
        </Focusable>
      </View>
  );
}

const button = {
  width: 600,
  height: 80,
  backgroundColor: "#D8D8D8",
  justifyContent: 'center',
  alignItems: 'center',
  marginBottom: 20,
};

const buttonText = {
  color: "#5D5D5D",
  fontSize: 24,
  fontWeight: 'bold'
};

const styles = {
  focused: {
    button: {
      ...button,
      backgroundColor: "#0081C8",
      shadowColor: "#000",
      shadowOffset: {
        width: 0,
        height: 6,
      },
      width: 650,
      shadowOpacity: 0.37,
      shadowRadius: 7.49,
      elevation: 12,
    },
    buttonText: {
      ...buttonText,
      color: "#ffffff"
    }
  },
  default: {
    button,
    buttonText
  }
};
