import React, { useState } from "react";
import PropTypes from "prop-types";

import { View, TextInput, findNodeHandle, Keyboard } from "react-native";
import { inputFieldStyle } from "../../../Utils/Customization";
import { KeyboardAwareScrollView } from "react-native-keyboard-aware-scroll-view";
import { useDimensions } from "@applicaster/zapp-react-native-utils/reactHooks/layout";
import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";

import { container } from "../../Styles";
import { validateSignUpData } from "../../../Utils/Account";
import { useBackHandler } from "../../../Utils/Hooks";
import ActionButton from "../../UIComponents/Buttons/ActionButton.js";
import TitleLabel from "../../UIComponents/TitleLabel";
import BackButton from "../../UIComponents/Buttons/BackButton";

const SignUpMobile = (props) => {
  const [fullName, setFullName] = useState(null);
  const [email, setEmail] = useState(null);
  const [passwordConfirmation, setPasswordConfirmation] = useState(null);
  const [password, setPassword] = useState(null);
  const { width: screenWidth } = useDimensions("window");

  const { screenStyles, screenLocalizations } = props;
  const textInputStyle = inputFieldStyle(screenStyles);

  const signUp = () => {
    const { createAccount, onSignUpError } = props;
    const validate = validateSignUpData(
      { fullName, email, password, passwordConfirmation },
      screenLocalizations
    );

    Keyboard.dismiss();

    if (validate instanceof Error) {
      onSignUpError({
        title: screenLocalizations.signup_title_validation_error,
        message: validate.message,
      });
    } else {
      createAccount({
        fullName,
        email,
        password,
      });
    }
  };

  const hardwareBack = () => {
    props?.onBackButton();
    return true;
  };

  useBackHandler(hardwareBack);

  const scrollToInput = (reactNode) => {
    this.scroll.props.scrollToFocusedInput(reactNode, 150, 0);
  };

  return (
    <View style={{ ...container, width: screenWidth }}>
      <BackButton
        title={screenLocalizations.back_button_text}
        screenStyles={screenStyles}
        onPress={props?.onBackButton}
      />
      <KeyboardAwareScrollView
        innerRef={(ref) => {
          this.scroll = ref;
        }}
        keyboardShouldPersistTaps="handled"
        extraScrollHeight={65}
        scrollEnabled={false}
        showsVerticalScrollIndicator={false}
        enableOnAndroid={true}
      >
        <TitleLabel
          screenStyles={screenStyles}
          title={screenLocalizations.title_font_text}
        />
        <TextInput
          onSubmitEditing={() => {
            this.emailTextInput.focus();
            scrollToInput(findNodeHandle(this.emailTextInput));
          }}
          onFocus={(event) => {
            scrollToInput(findNodeHandle(event.target));
          }}
          blurOnSubmit={false}
          autoCapitalize="words"
          placeholder={screenLocalizations.fields_name_text}
          placeholderTextColor={
            screenStyles?.fields_placeholder_font_color || "white"
          }
          style={textInputStyle}
          value={fullName}
          onChangeText={setFullName}
        />
        <TextInput
          ref={(input) => {
            this.emailTextInput = input;
          }}
          onFocus={(event) => {
            scrollToInput(findNodeHandle(event.target));
          }}
          onSubmitEditing={() => {
            this.passwordTextInput.focus();
          }}
          blurOnSubmit={false}
          autoCapitalize="none"
          placeholder={screenLocalizations.fields_email_text}
          placeholderTextColor={
            screenStyles?.fields_placeholder_font_color || "white"
          }
          style={textInputStyle}
          value={email}
          onChangeText={setEmail}
        />
        <TextInput
          ref={(input) => {
            this.passwordTextInput = input;
          }}
          onFocus={(event) => {
            scrollToInput(findNodeHandle(event.target));
          }}
          onSubmitEditing={() => {
            this.passwordConfirmationTextInput.focus();
            scrollToInput(findNodeHandle(this.passwordConfirmationTextInput));
          }}
          blurOnSubmit={false}
          autoCapitalize="none"
          placeholder={screenLocalizations.fields_password_text}
          placeholderTextColor={
            screenStyles?.fields_placeholder_font_color || "white"
          }
          style={textInputStyle}
          value={password}
          onChangeText={setPassword}
          secureTextEntry
          textContentType={"password"}
        />
        <TextInput
          ref={(input) => {
            this.passwordConfirmationTextInput = input;
          }}
          onSubmitEditing={() => {
            Keyboard.dismiss();
          }}
          returnKeyType={platformSelect({
            ios: "done",
            android: "none",
          })}
          blurOnSubmit={false}
          autoCapitalize="none"
          placeholder={screenLocalizations.fields_password_confirmation_text}
          placeholderTextColor={
            screenStyles?.fields_placeholder_font_color || "white"
          }
          onFocus={(event) => {
            scrollToInput(findNodeHandle(event.target));
          }}
          style={textInputStyle}
          value={passwordConfirmation}
          onChangeText={setPasswordConfirmation}
          secureTextEntry
        />
        <ActionButton
          screenStyles={screenStyles}
          title={screenLocalizations.action_button_signup_text}
          onPress={signUp}
        />
      </KeyboardAwareScrollView>
    </View>
  );
};

SignUpMobile.propTypes = {
  createAccount: PropTypes.func,
  onBackButton: PropTypes.func,
  onSignUpError: PropTypes.func,
  screenStyles: PropTypes.shape({
    fields_placeholder_font_color: PropTypes.string,
  }),
  screenLocalizations: PropTypes.shape({
    title_font_text: PropTypes.string,
    fields_email_text: PropTypes.string,
    fields_password_text: PropTypes.string,
    fields_name_text: PropTypes.string,
    action_button_login_text: PropTypes.string,
    fields_password_confirmation_text: PropTypes.string,
    action_button_signup_text: PropTypes.string,
    signup_title_validation_error: PropTypes.string,
    login_email_validation_error: PropTypes.string,
    signup_password_validation_error: PropTypes.string,
    signup_password_confirmation_validation_error: PropTypes.string,
    signup_name_validation_error: PropTypes.string,
    back_button_text: PropTypes.string,
  }),
};

SignUpMobile.defaultProps = {
  screenStyles: {},
  screenLocalizations: {},
};

export default SignUpMobile;
