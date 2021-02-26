import React, { useState, useEffect } from "react";
import {
  View,
  TextInput,
  findNodeHandle,
  Keyboard,
  BackHandler,
} from "react-native";
import PropTypes from "prop-types";
import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";

import { useDimensions } from "@applicaster/zapp-react-native-utils/reactHooks/layout";
import { KeyboardAwareScrollView } from "react-native-keyboard-aware-scroll-view";
import { inputFieldStyle } from "../../../Utils/Customization";
import { validateNewPassword } from "../../../Utils/Account";
import { container } from "../../Styles";
import ActionButton from "../../UIComponents/Buttons/ActionButton.js";
import TitleLabel from "../../UIComponents/TitleLabel";
import BackButton from "../../UIComponents/Buttons/BackButton";

const SetNewPasswordMobile = (props) => {
  const [passwordConfirmation, setPasswordConfirmation] = useState(null);
  const [password, setPassword] = useState(null);
  const [token, setToken] = useState(null);
  const { width: screenWidth } = useDimensions("window");

  const { screenStyles, screenLocalizations } = props;
  const textInputStyle = inputFieldStyle(screenStyles);

  let stillMounted = true;

  const hardwareBack = () => {
    props?.onBackButton();
    return true;
  };

  useEffect(() => {
    BackHandler.addEventListener("hardwareBackPress", hardwareBack);
    return () => {
      stillMounted = false;
      BackHandler.removeEventListener("hardwareBackPress", hardwareBack);
    };
  }, []);

  const onPressSetNewPasswordButton = () => {
    const { setNewPasswordCallback, onError } = props;
    const validate = validateNewPassword({ token, password, passwordConfirmation }, screenLocalizations);

    Keyboard.dismiss();

    if (validate instanceof Error) {
      onError({
        title: screenLocalizations.new_password_title_validation_error,
        message: validate.message
      });
    } else {
      setNewPasswordCallback({
        token,
        password
      });
    }
  };

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
            this.passwordTextInput.focus();
            scrollToInput(findNodeHandle(this.passwordTextInput));
          }}
          onFocus={(event) => {
            scrollToInput(findNodeHandle(event.target));
          }}
          blurOnSubmit={false}
          autoCapitalize="words"
          placeholder={screenLocalizations.fields_token_text}
          placeholderTextColor={
            screenStyles?.fields_placeholder_font_color || "white"
          }
          style={textInputStyle}
          value={token}
          onChangeText={setToken}
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
          placeholder={screenLocalizations.fields_set_new_password_text}
          placeholderTextColor={
            screenStyles?.fields_placeholder_font_color || "white"
          }
          style={textInputStyle}
          value={password}
          onChangeText={setPassword}
          secureTextEntry
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
          paddingTop={25}
          title={screenLocalizations.action_button_set_new_password_text}
          onPress={onPressSetNewPasswordButton}
        />
      </KeyboardAwareScrollView>
    </View>
  );
};

SetNewPasswordMobile.propTypes = {
  setNewPasswordCallback: PropTypes.func,
  onBackButton: PropTypes.func,
  onError: PropTypes.func,
  screenStyles: PropTypes.shape({
    fields_placeholder_font_color: PropTypes.string,
  }),
  screenLocalizations: PropTypes.shape({
    fields_token_text: PropTypes.string,
    title_font_text: PropTypes.string,
    fields_set_new_password_text: PropTypes.string,
    fields_password_confirmation_text: PropTypes.string,
    action_button_set_new_password_text: PropTypes.string,
    new_password_title_validation_error: PropTypes.string,
    new_password_token_validation_error: PropTypes.string,
    back_button_text: PropTypes.string,
  }),
};

SetNewPasswordMobile.defaultProps = {
  screenStyles: {},
  screenLocalizations: {},
};

export default SetNewPasswordMobile;
