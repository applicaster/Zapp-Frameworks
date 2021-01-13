import React, { useState } from "react";
import * as R from "ramda";
import { View, ViewPropTypes, StyleSheet, Text } from "react-native";
import PropTypes from "prop-types";
import { identity } from "ramda";
import { FocusableGroup } from "@applicaster/zapp-react-native-ui-components/Components/FocusableGroup";
import { focusManager } from "@applicaster/zapp-react-native-utils/appUtils";
import { findNextEmptyLabel } from "../../../Utils/Forms";
import { isWebBasedPlatform } from "../../../Utils/Platform";

import FocusableTextInput from "../../UIComponents/FocusableTextInput";
import Button from "../../UIComponents/Buttons/FocusableButton";
import colors from "../../../colors";
import {
  mapKeyToStyle,
  splitInputTypeStyles,
} from "../../../Utils/Customization";

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

const LoginControls = ({ style, errorMessage, onLogin, screenStyles, screenLocalizations }) => {
  const [usernameValue, setUsername] = useState("");
  const [passwordValue, setPassword] = useState("");

  const groupId = "login-form";

  const onPress = () => {
    onLogin({ email: usernameValue, password: passwordValue });
  };

  const handleInputChange = (setter) => (text) => {
    setter(text);
  };

  const handleEditingEnd = (label) => () => {
    // TODO: implement focus switching on Samsung TV
    if (isWebBasedPlatform) return null;
    /**
     * Wait for the focus manager to finish previous focusing job
     * (Bit of the hack but it works well from the UX point of view)
     */
    setTimeout(() => {
      const usernameInputId = "login-input";
      const passwordInputId = "password-input";
      const loginButtonId = `${groupId}-LOGIN`;
      const focusOnItem = (item) =>
        focusManager.forceFocusOnFocusable({ itemId: item });

      const labels = [
        { label: "login-input", value: usernameValue },
        { label: "password-input", value: passwordValue },
      ];

      const nextEmptyLabel = findNextEmptyLabel(label, labels);

      switch (nextEmptyLabel) {
        case "login-input":
          focusOnItem(usernameInputId);
          break;
        case "password-input":
          focusOnItem(passwordInputId);
          break;
        default:
          focusOnItem(loginButtonId);
      }
    }, 1000);
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
      <FocusableGroup id={groupId} shouldUsePreferredFocus isParallaxDisabled>
        <FocusableTextInput
          groupId={groupId}
          placeholder={screenLocalizations.fields_email_text}
          value={usernameValue}
          onChangeText={handleInputChange(setUsername)}
          label="login-input"
          onEndEditing={handleEditingEnd("login-input")}
          preferredFocus
          textInputStyles={loginInputStyles}
        />
        <FocusableTextInput
          groupId={groupId}
          placeholder={screenLocalizations.fields_password_text}
          secureTextEntry={true}
          value={passwordValue}
          onChangeText={handleInputChange(setPassword)}
          onEndEditing={handleEditingEnd("password-input")}
          label="password-input"
          textInputStyles={passwordInputStyles}
        />
        <Button
          {...{
            label: screenLocalizations.action_button_login_text,
            onPress,
            groupId,
            backgroundColor: screenStyles.login_action_button_background,
            backgroundColorFocused:
              screenStyles.login_action_button_background_focused,
            textColorFocused:
              screenStyles.login_action_button_fontcolor_focused,
            textStyles: buttonTextStyles,
            borderRadius: screenStyles.login_action_button_border_radius,
          }}
        />
      </FocusableGroup>
    </View>
  );
};

LoginControls.propTypes = {
  style: ViewPropTypes.style,
  onLogin: PropTypes.func,
  errorMessage: PropTypes.string,
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
