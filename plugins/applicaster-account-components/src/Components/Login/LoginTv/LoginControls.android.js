import React, { useState } from "react";
import * as R from "ramda";
import { View, ViewPropTypes, StyleSheet, Text } from "react-native";

import PropTypes from "prop-types";
import { identity } from "ramda";
import {
  useInitialFocus,
  useFocusManager,
} from "@applicaster/zapp-react-native-utils/focusManager";

import FocusableTextInput from "../../UIComponents/FocusableTextInput";
import Button from "../../UIComponents/Buttons/FocusableButton";
import { findNextEmptyLabel } from "../../../Utils/Forms";

import colors from "../../../colors";
import {
  mapKeyToStyle,
  splitInputTypeStyles,
} from "../../../Utils/Customization";

const groupId = "login-controls";

const styles = StyleSheet.create({
  errorMessage: {
    position: "absolute",
    height: 32,
    color: colors.grayLighter,
    fontSize: 24,
    lineHeight: 32,
    width: "100%",
    textAlign: "center",
    fontWeight: "500",
    transform: [{ translateY: -115 }],
  },
});

const LoginControls = ({
  style,
  errorMessage,
  onLogin,
  screenStyles,
  focused,
  parentFocus,
  screenLocalizations,
}) => {
  const [usernameValue, setUsername] = useState("");
  const [passwordValue, setPassword] = useState("");
  const loginInputRef = React.useRef(null);
  const passwordInputRef = React.useRef(null);
  const loginButtonRef = React.useRef(null);
  const [initialFocusable, setInitialFocusable] = useState(loginInputRef);
  const { setFocus } = useFocusManager();

  React.useEffect(() => {
    focused && setInitialFocusable(loginButtonRef);
  }, [focused]);

  useInitialFocus(focused, initialFocusable);

  const onPress = () => {
    onLogin({ email: usernameValue, password: passwordValue });
  };

  const handleInputChange = (setter) => (text) => {
    setter(text);
  };

  const handleEditingEnd = (label) => () => {
    const labels = [
      { label: "login-input", value: usernameValue },
      { label: "password-input", value: passwordValue },
    ];

    const nextEmptyLabel = findNextEmptyLabel(label, labels);

    switch (nextEmptyLabel) {
      case "login-input":
        setFocus(loginInputRef);
        break;
      case "password-input":
        setFocus(passwordInputRef);
        break;
      default:
        setFocus(loginButtonRef);
    }
  };

  const buttonTextStyles = React.useMemo(
    () => mapKeyToStyle("login_action_button", screenStyles),
    []
  );

  const loginInputStyles = React.useMemo(
    () =>
      R.compose(
        splitInputTypeStyles,
        mapKeyToStyle("email_input")
      )(screenStyles),
    []
  );

  const passwordInputStyles = React.useMemo(
    () =>
      R.compose(
        splitInputTypeStyles,
        mapKeyToStyle("password_input")
      )(screenStyles),
    []
  );
  return (
    <View style={style}>
      <Text style={styles.errorMessage}>{errorMessage}</Text>
      <FocusableTextInput
        ref={loginInputRef}
        autoCompleteType={"email"}
        placeholder={screenLocalizations.fields_email_text}
        value={usernameValue}
        onChangeText={handleInputChange(setUsername)}
        label="login-input"
        onEndEditing={handleEditingEnd("login-input")}
        preferredFocus
        nextFocusUp={parentFocus.nextFocusUp}
        nextFocusDown={passwordInputRef}
        textInputStyles={loginInputStyles}
        groupId={groupId}
      />
      <FocusableTextInput
        groupId={groupId}
        ref={passwordInputRef}
        placeholder={screenLocalizations.fields_password_text}
        secureTextEntry={true}
        value={passwordValue}
        onChangeText={handleInputChange(setPassword)}
        onEndEditing={handleEditingEnd("password-input")}
        label="password-input"
        textInputStyles={passwordInputStyles}
        nextFocusUp={loginInputRef}
        nextFocusDown={loginButtonRef}
      />
      <Button
        ref={loginButtonRef}
        nextFocusUp={passwordInputRef}
        nextFocusDown={parentFocus.nextFocusDown}
        {...{
          label: screenLocalizations.action_button_login_text,
          onPress,
          groupId: groupId,
          backgroundColor: screenStyles.login_action_button_background,
          backgroundColorFocused:
            screenStyles.login_action_button_background_focused,
          textColorFocused: screenStyles.login_action_button_fontcolor_focused,
          textStyles: buttonTextStyles,
          borderRadius: screenStyles.login_action_button_border_radius,
        }}
      />
    </View>
  );
};

LoginControls.propTypes = {
  style: ViewPropTypes.style,
  onLogin: PropTypes.func,
  errorMessage: PropTypes.string,
  parentFocus: PropTypes.object,
  focused: PropTypes.bool,
  screenStyles: PropTypes.shape({
    login_action_button_background: PropTypes.string,
    login_action_button_background_focused: PropTypes.string,
    login_action_button_fontcolor_focused: PropTypes.string,
    login_action_button_border_radius: PropTypes.number,
  }),
  screenLocalizations: PropTypes.shape({
    fields_email_text: PropTypes.string,
    fields_password_text: PropTypes.string,
    action_button_login_text: PropTypes.string,
  }),
};

LoginControls.defaultProps = {
  onLogin: identity,
  screenStyles: {},
  screenLocalizations: {},
};

export default LoginControls;
