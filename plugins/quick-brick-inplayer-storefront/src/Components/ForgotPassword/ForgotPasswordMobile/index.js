import React, { useState } from "react";
import { View, TextInput, findNodeHandle, Keyboard } from "react-native";
import PropTypes from "prop-types";

import { useDimensions } from "@applicaster/zapp-react-native-utils/reactHooks/layout";
import { KeyboardAwareScrollView } from "react-native-keyboard-aware-scroll-view";
import { inputFieldStyle } from "../../../Utils/Customization";
import { useBackHandler } from "../../../Utils/Hooks";
import { isValidEmail } from "../../../Utils/Account";
import { container } from "../../Styles";
import ActionButton from "../../UIComponents/Buttons/ActionButton.js";
import TitleLabel from "../../UIComponents/TitleLabel";
import BackButton from "../../UIComponents/Buttons/BackButton";

const ForgotPasswordMobile = (props) => {
  const [email, setEmail] = useState(null);
  const { width: screenWidth } = useDimensions("window");

  const { screenStyles, screenLocalizations } = props;
  const textInputStyle = inputFieldStyle(screenStyles);

  let stillMounted = true;

  const hardwareBack = () => {
    props?.onBackButton();
    return true;
  };

  useBackHandler(hardwareBack);

  const onPressRequestPasswordButton = () => {
    const { forgotPasswordFlowCallback, onError } = props;

    Keyboard.dismiss();

    if (isValidEmail(email)) {
      forgotPasswordFlowCallback({ email });
    } else {
      onError({
        title: screenLocalizations.login_title_validation_error,
        message: screenLocalizations.login_email_validation_error,
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

        <ActionButton
          screenStyles={screenStyles}
          paddingTop={25}
          title={screenLocalizations.action_button_forgot_password_text}
          onPress={onPressRequestPasswordButton}
        />
      </KeyboardAwareScrollView>
    </View>
  );
};

ForgotPasswordMobile.propTypes = {
  forgotPasswordFlowCallback: PropTypes.func,
  onBackButton: PropTypes.func,
  onError: PropTypes.func,
  screenStyles: PropTypes.shape({
    fields_placeholder_font_color: PropTypes.string,
  }),
  screenLocalizations: PropTypes.shape({
    title_font_text: PropTypes.string,
    fields_email_text: PropTypes.string,
    action_button_forgot_password_text: PropTypes.string,
    login_title_validation_error: PropTypes.string,
    login_email_validation_error: PropTypes.string,
    back_button_text: PropTypes.string,
  }),
};

ForgotPasswordMobile.defaultProps = {
  screenStyles: {},
  screenLocalizations: {},
};

export default ForgotPasswordMobile;
