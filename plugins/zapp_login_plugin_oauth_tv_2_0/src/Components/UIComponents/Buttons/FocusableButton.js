import * as React from "react";
import { View, Text, StyleSheet } from "react-native";
import PropTypes from "prop-types";
import { identity } from "ramda";
import { Focusable } from "@applicaster/zapp-react-native-ui-components/Components/Focusable";

import colors from "../../../colors";

const localStyles = StyleSheet.create({
  button: {
    width: 556,
    height: 88,
    backgroundColor: colors.grayDark,
    borderRadius: 4,
    alignItems: "center",
    justifyContent: "center",
  },
  buttonText: {
    color: colors.white,
    fontSize: 24,
    fontWeight: "bold",
  },
  buttonActive: {
    backgroundColor: colors.buttonActive,
  },
});

const Button = React.forwardRef(
  (
    {
      onPress,
      label,
      groupId,
      backgroundColor,
      backgroundColorFocused,
      textColorFocused,
      textStyles,
      borderRadius,
      nextFocusUp,
      nextFocusDown,
    },
    ref
  ) => {
    const getBackgroundColor = React.useCallback(
      (focused) => ({
        backgroundColor: focused ? backgroundColorFocused : backgroundColor,
      }),
      []
    );

    const getTextColor = React.useCallback(
      (focused) => ({
        color: focused ? textColorFocused : textStyles.color,
      }),
      []
    );

    return (
      <Focusable
        ref={ref}
        id={`${groupId}-${label}`}
        groupId={groupId}
        onPress={onPress}
        nextFocusUp={nextFocusUp}
        nextFocusDown={nextFocusDown}
      >
        {(focused) => (
          <View
            style={[
              localStyles.button,
              getBackgroundColor(focused),
              { borderRadius },
            ]}
          >
            <Text style={[textStyles, getTextColor(focused)]}>{label}</Text>
          </View>
        )}
      </Focusable>
    );
  }
);

Button.propTypes = {
  onPress: PropTypes.func,
  label: PropTypes.string,
  groupId: PropTypes.string,
  backgroundColor: PropTypes.string,
  backgroundColorFocused: PropTypes.string,
  textColor: PropTypes.string,
  textColorFocused: PropTypes.string,
  textStyles: PropTypes.object,
  borderRadius: PropTypes.number,
  nextFocusUp: PropTypes.object,
  nextFocusDown: PropTypes.object,
};

Button.defaultProps = {
  onPress: identity,
  backgroundColor: colors.grayDark,
  backgroundColorFocused: colors.buttonActive,
  textColor: colors.white,
  textColorFocused: colors.white,
  textStyles: {},
  borderRadius: 5,
};

Button.displayName = "Button";

export default Button;
