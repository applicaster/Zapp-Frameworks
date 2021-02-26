import React, { useRef } from "react";
import PropTypes from "prop-types";

import { StyleSheet } from "react-native";
import { Focusable } from "@applicaster/zapp-react-native-ui-components/Components/Focusable";
import { TextInputTv } from "@applicaster/zapp-react-native-ui-components/Components/TextInputTv";

import colors from "../../../colors";

const styles = StyleSheet.create({
  textInput: {
    height: 88,
    width: 556,
    marginBottom: 24,
    borderColor: colors.gray,
    borderRadius: 6,
    borderWidth: 3,
    fontSize: 28,
    color: colors.gray,
    opacity: 1,
    backgroundColor: colors.transparent,
    borderStyle: "solid",
    paddingLeft: 24,
    paddingRight: 24,
    paddingTop: 22,
    paddingBottom: 22,
  },
  inputFocused: {
    borderColor: colors.inputBorderColorActive,
    color: colors.white,
  },
  inputNotEmpty: {
    borderColor: colors.white,
    color: colors.gray,
  },
});

const FocusableTextInput = React.forwardRef(
  (
    {
      value,
      onChangeText,
      onEndEditing,
      label,
      placeholder,
      secureTextEntry,
      nextFocusUp,
      nextFocusDown,
      textInputStyles,
    },
    ref
  ) => {
    const inputRef = useRef(null);

    const focusablePressHandler = () => {
      inputRef.current.focus();
    };

    const getTextInputStyles = (focused) => {
      return [
        { ...styles.textInput, ...textInputStyles.default },
        value && { ...styles.inputNotEmpty, ...textInputStyles.filled },
        focused && { ...styles.inputFocused, ...textInputStyles.focused },
      ];
    };

    const getFocusableStyles = () => {
      const { marginBottom, height } = StyleSheet.flatten(styles.textInput);
      return {
        height: Number(marginBottom) + Number(height),
      };
    };

    return (
      <Focusable
        ref={ref}
        id={label}
        onPress={focusablePressHandler}
        style={getFocusableStyles()}
        {...{ nextFocusUp, nextFocusDown }}
      >
        {(focused) => (
          <TextInputTv
            ref={inputRef}
            style={getTextInputStyles(focused)}
            {...{
              placeholder,
              onChangeText,
              value,
              secureTextEntry,
              onEndEditing,
              placeholderTextColor: colors.gray,
            }}
          />
        )}
      </Focusable>
    );
  }
);

FocusableTextInput.propTypes = {
  value: PropTypes.string,
  onChangeText: PropTypes.func.isRequired,
  label: PropTypes.string.isRequired,
  placeholder: PropTypes.string,
  secureTextEntry: PropTypes.bool,
  preferredFocus: PropTypes.bool,
  groupId: PropTypes.string.isRequired,
  onEndEditing: PropTypes.func,
  textInputStyles: PropTypes.shape({
    default: PropTypes.object,
    focused: PropTypes.object,
    filled: PropTypes.object,
  }),
  focused: PropTypes.bool,
  nextFocusUp: PropTypes.object,
  nextFocusDown: PropTypes.object,
};

FocusableTextInput.defaultProps = {
  secureTextEntry: false,
  textInputStyles: {
    default: {},
    focused: {},
    filled: {},
  },
};

FocusableTextInput.displayName = "FocusableTextInput";

export default FocusableTextInput;
