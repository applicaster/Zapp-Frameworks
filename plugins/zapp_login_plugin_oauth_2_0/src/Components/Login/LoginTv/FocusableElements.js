import React from "react";
import { View } from "react-native";
import PropTypes from "prop-types";

import LoginControls from "./LoginControls";
import SignUpControls from "./SignUpControls";

const FocusableElements = ({
  onLogin,
  errorMessage,
  screenStyles,
  loginStyles,
  signupStyles,
  onSignup,
  screenLocalizations,
}) => {
  return (
    <View>
      <LoginControls
        {...{
          style: loginStyles,
          onLogin,
          errorMessage,
          screenStyles,
          screenLocalizations,
        }}
      />
      <SignUpControls
        {...{
          style: signupStyles,
          onPress: onSignup,
          screenStyles,
          screenLocalizations,
        }}
      />
    </View>
  );
};

FocusableElements.propTypes = {
  onLogin: PropTypes.func,
  errorMessage: PropTypes.string,
  loginStyles: PropTypes.object,
  signupStyles: PropTypes.object,
  onSignup: PropTypes.func,
  screenStyles: PropTypes.object,
  screenLocalizations: PropTypes.object,
};

FocusableElements.defaultProps = {
  onLogin: () => {},
  loginStyles: {},
  signupStyles: {},
  onSignup: () => {},
  screenStyles: {},
  screenLocalizations: {},
};

export default FocusableElements;
