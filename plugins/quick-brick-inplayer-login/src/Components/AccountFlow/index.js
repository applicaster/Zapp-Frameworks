import React, { useState, useLayoutEffect } from "react";
import { View, SafeAreaView, Keyboard, Platform } from "react-native";
import PropTypes from "prop-types";

import ParentLockPlugin from "@applicaster/quick-brick-parent-lock";
import Login from "../Login";
import ForgotPassword from "../ForgotPassword";
import SetNewPassword from "../SetNewPassword";
import LoadingScreen from "../LoadingScreen";
import SignUp from "../SignUp";
import { container } from "../Styles";
import { createLogger, Subsystems } from "../../Services/LoggerService";

export const logger = createLogger({
  subsystem: Subsystems.ACCOUNT,
  category: "",
});

const containerStyle = (screenStyles) => {
  return {
    ...container,
    backgroundColor: screenStyles?.background_color,
  };
};

const ScreensData = {
  EMPTY: "Empty",
  LOGIN: "Login",
  SIGN_UP: "SignUp",
  FORGOT_PASSWORD: "ForgotPassword",
  SET_NEW_PASSWORD: "SetNewPassword",
  PARENT_LOCK: "ParentLock",
};

const AccountFlow = (props) => {
  let stillMounted = true;

  const [screen, setScreen] = useState(ScreensData.EMPTY);

  const {
    shouldShowParentLock,
    accountFlowCallback,
    screenStyles,
    setParentLockWasPresented,
    loading,
    lastEmailUsed,
    onLogin,
    onCreateAccount,
    onNewPasswordChange,
    onForgotPassword,
    onError,
  } = props;

  useLayoutEffect(() => {
    if (shouldShowParentLock) {
      presentParentLock();
    } else {
      authenticateUser();
    }

    return () => {
      stillMounted = false;
    };
  }, []);

  const authenticateUser = async () => {
    setScreen(ScreensData.LOGIN);
  };

  const presentParentLock = () => {
    setScreen(ScreensData.PARENT_LOCK);
    setParentLockWasPresented?.(true);
  };

  const parentLockCallback = async (result) => {
    const success = result.success;
    let eventMessage = "Parent lock finished";

    if (success) {
      eventMessage = `${eventMessage}, presenting login screen`;
      await authenticateUser();
    } else {
      accountFlowCallback({ success: false });
    }

    logger.debug({
      message: eventMessage,
      data: {
        succeed,
      },
    });
  };

  const login = ({ email, password }) => {
    const trimmedEmail = email.trim();
    Keyboard.dismiss();

    onLogin?.({ email: trimmedEmail, password, setScreen });
  };

  const createAccount = ({ fullName, email, password }) => {
    const trimmedEmail = email.trim();
    Keyboard.dismiss();

    onCreateAccount?.({ fullName, email: trimmedEmail, password, setScreen });
  };

  const setNewPasswordCallback = ({ password, token }) => {
    Keyboard.dismiss();
    onNewPasswordChange?.({ password, token, setScreen });
  };

  const forgotPasswordFlowCallback = ({ email }) => {
    const trimmedEmail = email.trim();
    Keyboard.dismiss();

    onForgotPassword?.({ email: trimmedEmail, setScreen });
  };

  const onPresentForgotPasswordScreen = () => {
    stillMounted && setScreen(ScreensData.FORGOT_PASSWORD);
  };

  const renderAuthenticationScreen = () => {
    switch (screen) {
      case ScreensData.LOGIN:
        return onLogin ? (
          <Login
            initialEmail={lastEmailUsed}
            login={login}
            signUp={() => {
              stillMounted && setScreen(ScreensData.SIGN_UP);
            }}
            onPresentForgotPasswordScreen={onPresentForgotPasswordScreen}
            onLoginError={onError}
            {...props}
          />
        ) : null;

      case ScreensData.SIGN_UP:
        return onCreateAccount ? (
          <SignUp
            createAccount={createAccount}
            onBackButton={() => {
              stillMounted && setScreen(ScreensData.LOGIN);
            }}
            onSignUpError={onError}
            {...props}
          />
        ) : null;
      case ScreensData.FORGOT_PASSWORD:
        return onForgotPassword ? (
          <ForgotPassword
            forgotPasswordFlowCallback={forgotPasswordFlowCallback}
            onBackButton={() => {
              stillMounted && setScreen(ScreensData.LOGIN);
            }}
            onError={onError}
            {...props}
          />
        ) : null;
      case ScreensData.SET_NEW_PASSWORD:
        return onNewPasswordChange ? (
          <SetNewPassword
            setNewPasswordCallback={setNewPasswordCallback}
            onBackButton={() => {
              stillMounted && setScreen(ScreensData.FORGOT_PASSWORD);
            }}
            onError={onError}
            {...props}
          />
        ) : null;
    }
    return null;
  };

  if (screen === ScreensData.PARENT_LOCK) {
    console.log("Parent lock!", ParentLockPlugin);
    return <ParentLockPlugin.Component callback={parentLockCallback} />;
  }

  const SafeArea = Platform.isTV ? View : SafeAreaView;

  return (
    <View style={containerStyle(screenStyles)}>
      <SafeArea style={container}>
        {renderAuthenticationScreen()}
        {loading && <LoadingScreen />}
      </SafeArea>
    </View>
  );
};

AccountFlow.propTypes = {
  configuration: PropTypes.object,
  setParentLockWasPresented: PropTypes.func,
  parentLockWasPresented: PropTypes.bool,
  shouldShowParentLock: PropTypes.func,
  accountFlowCallback: PropTypes.func,
  screenStyles: PropTypes.object,
  screenLocalizations: PropTypes.shape({
    login_title_error_text: PropTypes.string,
    signup_title_error_text: PropTypes.string,
    reset_password_success_title: PropTypes.string,
    reset_password_success_text: PropTypes.string,
    reset_password_error_title: PropTypes.string,
    reset_password_error_text: PropTypes.string,
    request_password_success_title: PropTypes.string,
    request_password_error_title: PropTypes.string,
    request_password_error_text: PropTypes.string,
  }),
};

AccountFlow.defaultProps = {
  configuration: {},
  screenStyles: {},
  screenLocalizations: {},
};

export default AccountFlow;
