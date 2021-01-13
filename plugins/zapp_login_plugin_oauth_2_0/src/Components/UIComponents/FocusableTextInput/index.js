import React, { useEffect, useRef } from "react";
import PropTypes from "prop-types";
import * as R from "ramda";

import { StyleSheet } from "react-native";
import { Focusable } from "@applicaster/zapp-react-native-ui-components/Components/Focusable";
import { TextInputTv } from "@applicaster/zapp-react-native-ui-components/Components/TextInputTv";

import { isWebBasedPlatform } from "../../../Utils/Platform";
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

const FocusableTextInput = ({
  value,
  onChangeText,
  onEndEditing,
  label,
  placeholder,
  secureTextEntry,
  preferredFocus,
  groupId,
  textInputStyles,
}) => {
  const inputRef = useRef();

  const handlePressDone = () => {
    inputRef.current.blur();
    onEndEditing();
  };

  const handlePressCancel = () => {
    inputRef.current.blur();
  };

  const listener = (event) => {
    const isDone = R.propEq("keyCode", 65376);
    const isCancel = R.propEq("keyCode", 65376);
    const isReturn = R.propEq("keyCode", 65385);
    R.cond([
      [isDone, handlePressDone],
      [R.anyPass([isCancel, isReturn]), handlePressCancel],
    ])(event);
  };

  useEffect(() => {
    if (isWebBasedPlatform) {
      const focusableElement = document.getElementById(
        `focusable-${groupId}-${label}`
      );
      focusableElement.addEventListener("keydown", listener);

      return () => {
        focusableElement.removeEventListener("keydown", listener);
      };
    }
  }, []);

  const focusablePressHandler = () => {
    inputRef.current.focus();
  };

  const focusableBlurHandler = () => {
    if (isWebBasedPlatform) {
      inputRef.current.blur();
    }
  };

  const getTextInputStyles = (focused) => {
    return [
      StyleSheet.compose([styles.textInput, textInputStyles.default]),
      value &&
        StyleSheet.compose([styles.inputNotEmpty, textInputStyles.filled]),
      focused &&
        StyleSheet.compose([styles.inputFocused, textInputStyles.focused]),
      isWebBasedPlatform && {
        outlineWidth: 0,
        boxSizing: "border-box",
        placeholderTextColor: getPlaceholderColor(),
      },
    ];
  };

  const getPlaceholderColor = () => {
    return textInputStyles.default.placeholderTextColor || colors.grey
  }

  const getFocusableStyles = () => {
    const { marginBottom, height } = StyleSheet.flatten(styles.textInput);
    return {
      height: Number(marginBottom) + Number(height),
    };
  };

  return (
    <Focusable
      id={label}
      groupId={groupId}
      onPress={focusablePressHandler}
      onBlur={focusableBlurHandler}
      preferredFocus={preferredFocus}
      isParallaxDisabled
      style={getFocusableStyles()}
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
            placeholderTextColor: getPlaceholderColor(),
          }}
        />
      )}
    </Focusable>
  );
};

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
};

FocusableTextInput.defaultProps = {
  secureTextEntry: false,
  textInputStyles: {
    default: {},
    focused: {},
    filled: {},
  },
};

export default FocusableTextInput;
