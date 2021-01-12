import React, { useState, useEffect } from "react";
import {
  View,
  Text,
  TextInput,
  StyleSheet,
  TouchableOpacity,
  findNodeHandle,
  Keyboard,
} from "react-native";
import PropTypes from "prop-types";

import { useDimensions } from "@applicaster/zapp-react-native-utils/reactHooks/layout";
import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";
import { KeyboardAwareScrollView } from "react-native-keyboard-aware-scroll-view";
import { inputFieldStyle } from "../../../Utils/Customization";
import { isValidEmail } from "../../../Utils/Account";
import { container } from "../../Styles";
import ActionButton from "../../UIComponents/Buttons/ActionButton.js";
import TitleLabel from "../../UIComponents/TitleLabel";
import BackButton from "../../UIComponents/Buttons/BackButton";

const styles = StyleSheet.create({
  newUserButton: {
    height: 50,
    width: 250,
    alignItems: "center",
    justifyContent: "center",
    borderRadius: 50,
    alignSelf: "center",
  },
});

const forgotPasswordStyle = (screenStyles) => {
  return {
    fontFamily: platformSelect({
      ios: screenStyles?.forgot_password_font_ios,
      android: screenStyles?.forgot_password_font_android,
    }),
    fontSize: screenStyles?.forgot_password_font_size,
    color: screenStyles?.forgot_password_font_color,
    alignSelf: "center",
    textAlign: "center",
    marginBottom: 30,
    textDecorationLine: "underline",
  };
};

const newUserButtonStyle = (screenStyles) => {
  return {
    fontFamily: platformSelect({
      ios: screenStyles?.create_account_link_font_ios,
      android: screenStyles?.create_account_link_font_android,
    }),
    fontSize: screenStyles?.create_account_link_font_size,
    color: screenStyles?.create_account_link_font_color,
    textDecorationLine: "underline",
    alignSelf: "center",
    textAlign: "center",
  };
};

const LoginMobile = (props) => {
  const [email, setEmail] = useState(null);
  const [password, setPassword] = useState(null);
  const { width: screenWidth } = useDimensions("window");

  const { initialEmail, backButton, screenStyles, screenLocalizations } = props;
  const textInputStyle = inputFieldStyle(screenStyles);

  let stillMounted = true;

  useEffect(() => {
    return () => {
      stillMounted = false;
    };
  }, []);

  useEffect(() => {
    stillMounted && setEmail(initialEmail);
  }, [initialEmail]);

  const onPressLoginButton = () => {
    const { login, onLoginError } = props;

    Keyboard.dismiss();

    if (isValidEmail(email)) {
      login({ email, password });
    } else {
      onLoginError({
        title: screenLocalizations.login_title_validation_error,
        message: screenLocalizations.login_email_validation_error,
      });
    }
  };

  const onBackButton = () => {
    const { accountFlowCallback } = props;
    accountFlowCallback && accountFlowCallback(false);
  };

  const forgotPasswordButton = () => {
    const { onPresentForgotPasswordScreen } = props;
    onPresentForgotPasswordScreen && onPresentForgotPasswordScreen();
  };

  const renderCreateAccountButton = () => {
    return (
      <TouchableOpacity onPress={props?.signUp}>
        <View style={styles.newUserButton}>
          <Text style={newUserButtonStyle(screenStyles)}>
            {screenLocalizations.create_account_link_text}
          </Text>
        </View>
      </TouchableOpacity>
    );
  };

  const scrollToInput = (reactNode) => {
    this.scroll.props.scrollToFocusedInput(reactNode, 150, 0);
  };

  return (
    <View style={{ ...container, width: screenWidth }}>
      <BackButton
        title={screenLocalizations.back_button_text}
        disabled={!backButton}
        screenStyles={screenStyles}
        onPress={onBackButton}
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
          }}
          onFocus={(event) => {
            scrollToInput(findNodeHandle(event.target));
          }}
          blurOnSubmit={false}
          autoCapitalize="none"
          placeholder={screenLocalizations.fields_email_text}
          placeholderTextColor={
            screenStyles?.fields_placeholder_font_color || "white"
          }
          style={textInputStyle}
          value={email}
          onChangeText={stillMounted && setEmail}
        />

        <TextInput
          ref={(input) => {
            this.passwordTextInput = input;
          }}
          onFocus={(event) => {
            scrollToInput(findNodeHandle(event.target));
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
          placeholder={screenLocalizations.fields_password_text}
          placeholderTextColor={
            screenStyles?.fields_placeholder_font_color || "white"
          }
          style={textInputStyle}
          value={password}
          onChangeText={stillMounted && setPassword}
          secureTextEntry
        />
        <TouchableOpacity onPress={forgotPasswordButton}>
          <Text style={forgotPasswordStyle(screenStyles)}>
            {screenLocalizations.forgot_password_text}
          </Text>
        </TouchableOpacity>
        <ActionButton
          screenStyles={screenStyles}
          title={screenLocalizations.action_button_login_text}
          onPress={onPressLoginButton}
        />
        {renderCreateAccountButton()}
      </KeyboardAwareScrollView>
    </View>
  );
};

LoginMobile.propTypes = {
  backButton: PropTypes.bool,
  initialEmail: PropTypes.string,
  login: PropTypes.string,
  signUp: PropTypes.func,
  onPresentForgotPasswordScreen: PropTypes.func,
  onLoginError: PropTypes.func,
  accountFlowCallback: PropTypes.func,
  screenStyles: PropTypes.shape({
    forgot_password_font_ios: PropTypes.string,
    forgot_password_font_android: PropTypes.string,
    forgot_password_font_size: PropTypes.number,
    forgot_password_font_color: PropTypes.string,
    create_account_link_font_ios: PropTypes.string,
    create_account_link_font_android: PropTypes.string,
    create_account_link_font_size: PropTypes.number,
    create_account_link_font_color: PropTypes.string,
    fields_placeholder_font_color: PropTypes.string,
  }),
  screenLocalizations: PropTypes.shape({
    create_account_link_text: PropTypes.string,
    title_font_text: PropTypes.string,
    fields_email_text: PropTypes.string,
    fields_password_text: PropTypes.string,
    forgot_password_text: PropTypes.string,
    action_button_login_text: PropTypes.string,
    login_title_validation_error: PropTypes.string,
    login_email_validation_error: PropTypes.string,
    back_button_text: PropTypes.string,
  }),
};

LoginMobile.defaultProps = {
  screenStyles: {},
  screenLocalizations: {},
};

export default LoginMobile;
