import React from "react";
import * as R from "ramda";
import PropTypes from "prop-types";
import { View, Text, StyleSheet } from "react-native";
import { useDimensions } from "@applicaster/zapp-react-native-utils/reactHooks/layout";

import ClientLogo from "../../UIComponents/ClientLogo";
import { mapKeyToStyle } from "../../../Utils/Customization";
import { useBackHandler, useToggleNavBar } from "../../../Utils/Hooks";
import SignupControls from "./SignupControls";
import { validateSignUpData } from "../../../Utils/Account";

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: "center",
    paddingTop: 214,
  },
  title: {
    color: "rgba(33, 35, 36, 1)",
    fontSize: 60,
    marginBottom: 66,
  },
  clientLogoView: {
    height: 100,
    width: 350,
    position: "absolute",
    top: 58,
    left: 58,
  },
});

const SignUpMobile = (props) => {
  const { width: screenWidth } = useDimensions("window");
  const { screenStyles, screenLocalizations } = props;

  const signUp = ({ fullName, email, password }) => {
    const { createAccount, onSignUpError } = props;
    const validate = validateSignUpData({ fullName, email, password, passwordConfirmation: password }, screenLocalizations);

    if (validate instanceof Error) {
      onSignUpError({
        title: screenLocalizations.signup_title_validation_error,
        message: validate.message
      });
    } else {
      createAccount({
        fullName,
        email,
        password
      });
    }
  };

  const hardwareBack = () => {
    props?.onBackButton();
  };

  useBackHandler(hardwareBack);
  useToggleNavBar();

  const signupTextStyles = React.useMemo(
    () => mapKeyToStyle("signup_title", screenStyles) || {},
    []
  );

  return (
    <View style={[styles.container, { width: screenWidth || 1920 }]}>
      <View style={styles.clientLogoView}>
        <ClientLogo imageSrc={screenStyles.client_logo} />
      </View>
      <Text style={[styles.title, signupTextStyles]}>
        {screenLocalizations.signup_title_text}
      </Text>
      <SignupControls
        {...{
          screenStyles,
          screenLocalizations,
          onSignup: signUp,
        }}
      />
    </View>
  );
};

SignUpMobile.propTypes = {
  createAccount: PropTypes.func,
  onSignUpError: PropTypes.func,
  onBackButton: PropTypes.func,
  screenStyles: PropTypes.object,
  screenLocalizations: PropTypes.shape({
    signup_title_text: PropTypes.string,
    signup_title_validation_error: PropTypes.string,
    login_email_validation_error: PropTypes.string,
    signup_password_validation_error: PropTypes.string,
    signup_password_confirmation_validation_error: PropTypes.string,
    signup_name_validation_error: PropTypes.string,
  }),
};

SignUpMobile.defaultProps = {
  createAccount: R.identity,
  onSignUpError: R.identity,
  onBackButton: R.identity,
  screenStyles: {},
  screenLocalizations: {},
};

export default SignUpMobile;
