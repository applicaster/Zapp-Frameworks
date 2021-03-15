import React, { useState, useLayoutEffect } from "react";
import { View, SafeAreaView, Keyboard, Platform } from "react-native";
import PropTypes from "prop-types";
// https://github.com/testshallpass/react-native-dropdownalert#usage
import DropdownAlert from "react-native-dropdownalert";

import ParentLockPlugin from "@applicaster/quick-brick-parent-lock";
import Login from "../Login";
import ForgotPassword from "../ForgotPassword";
import SetNewPassword from "../SetNewPassword";
import LoadingScreen from "../LoadingScreen";
import SignUp from "../SignUp";
import { container } from "../Styles";
import * as InPlayerService from "../../Services/inPlayerService";
import { showAlert } from "../../Utils/Account";
import {
  createLogger,
  Subsystems,
  XRayLogLevel,
} from "../../Services/LoggerService";
import { isWebBasedPlatform } from "../../Utils/Platform";

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

const AccountFlow = (props) => {
  const ScreensData = {
    EMPTY: "Empty",
    LOGIN: "Login",
    SIGN_UP: "SignUp",
    FORGOT_PASSWORD: "ForgotPassword",
    SET_NEW_PASSWORD: "SetNewPassword",
    PARENT_LOCK: "ParentLock",
  };
  let stillMounted = true;

  const {
    configuration: {
      in_player_client_id: clientId,
      in_player_referrer: referrer,
      in_player_branding_id,
    },
  } = props;
  const brandingId = React.useMemo(() => {
    const parsedValue = parseInt(in_player_branding_id);
    return isNaN(parsedValue) ? null : parsedValue;
  }, []);

  const [loading, setLoading] = useState(true);
  const [screen, setScreen] = useState(ScreensData.EMPTY);
  const [lastEmailUsed, setLastEmailUsed] = useState(null);

  const {
    shouldShowParentLock,
    accountFlowCallback,
    screenStyles,
    screenLocalizations,
  } = props;

  useLayoutEffect(() => {
    InPlayerService.isAuthenticated(clientId)
      .then(async (isAuthenticated) => {
        let eventMessage = "Account Flow:";
        const event = logger
          .createEvent()
          .setLevel(XRayLogLevel.debug)
          .addData({ is_authenticated: isAuthenticated });

        if (stillMounted) {
          if (isAuthenticated) {
            eventMessage = `${eventMessage} access granted, flow completed`;
            accountFlowCallback({ success: true });
          } else {
            console.log({
              shouldShowParentLock,
              should1ShowParentLock: shouldShowParentLock(
                props.parentLockWasPresented
              ),
            });
            if (
              shouldShowParentLock &&
              shouldShowParentLock(props.parentLockWasPresented)
            ) {
              eventMessage = `${eventMessage} not granted, present parent lock`;
              presentParentLock();
            } else {
              eventMessage = `${eventMessage} not granted, present login screen`;
              await authenticateUser();
            }
          }
        }
        event.setMessage(eventMessage).send();
      })
      .finally(() => {
        stillMounted && setLoading(false);
      });
    return () => {
      stillMounted = false;
    };
  }, []);

  const authenticateUser = async () => {
    setLastEmailUsed((await InPlayerService.getLastEmailUsed()) || null);
    setScreen(ScreensData.LOGIN);
  };

  const presentParentLock = () => {
    setScreen(ScreensData.PARENT_LOCK);
    props.setParentLockWasPresented(true);
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

  const showAlertToUser = ({ title, message, type = "warn" }) => {
    logger.log({
      message: `Aller will be presented for user title: ${title}, message: ${message}, type: ${type}`,
      data: {
        title,
        message,
        type,
      },
    });

    Platform.isTV || isWebBasedPlatform
      ? showAlert(title, message)
      : this.dropDownAlertRef.alertWithType(type, title, message);
  };

  const maybeShowAlertToUser = (title) => async (error) => {
    const { response } = error;
    if (response && response.status >= 400 && response.status < 500) {
      const message = response.data.message;

      showAlertToUser({ title, message: message });
      stillMounted && setLoading(false);
    } else {
      logger.log({
        message: `Error: ${error}`,
        data: {
          error,
        },
      });
      throw error;
    }
  };

  const login = ({ email, password }) => {
    const trimmedEmail = email.trim();

    Keyboard.dismiss();
    stillMounted && setLoading(true);

    logger.debug({
      message: `Perform Login In task, email: ${trimmedEmail}, password: ${password}`,
      data: {
        email: trimmedEmail,
        password,
      },
    });

    InPlayerService.login({
      email: trimmedEmail,
      password,
      clientId,
      referrer,
    })
      .then(() => {
        logger.debug({
          message: `Login succeed, email: ${trimmedEmail}, password: ${password}`,
          data: {
            email: trimmedEmail,
            password,
          },
        });
        accountFlowCallback({ success: true });
      })
      .catch(maybeShowAlertToUser(screenLocalizations.login_title_error_text))
      .catch((error) => {
        logger.error({
          message: `Login failed, email: ${trimmedEmail}, password: ${password}`,
          data: {
            email: trimmedEmail,
            password,
            error,
          },
        });
        stillMounted && setLoading(false);
      });
  };

  const createAccount = ({ fullName, email, password }) => {
    const trimmedEmail = email.trim();

    Keyboard.dismiss();
    stillMounted && setLoading(true);

    logger.debug({
      message: `Perform Create Account task, email: ${trimmedEmail}, password: ${password}`,
      data: {
        email: trimmedEmail,
        password,
      },
    });

    InPlayerService.signUp({
      fullName,
      email: trimmedEmail,
      password,
      clientId,
      referrer,
      brandingId,
    })
      .then(() => {
        logger.debug({
          message: `Account Creation succeed, fullName: ${fullName}, email: ${trimmedEmail}, password: ${password}`,
          data: {
            email: trimmedEmail,
            password,
            fullName,
          },
        });
        accountFlowCallback({ success: true });
      })
      .catch(maybeShowAlertToUser(screenLocalizations.signup_title_error_text))
      .catch((error) => {
        logger.error({
          message: `Account Creation failed, fullName: ${fullName}, email: ${trimmedEmail}, password: ${password}`,
          data: {
            email: trimmedEmail,
            password,
            fullName,
            error,
          },
        });
        stillMounted && setLoading(false);
      });
  };

  const setNewPasswordCallback = ({ password, token }) => {
    Keyboard.dismiss();

    logger.debug({
      message: `Set new password task, password: ${password}, token: ${token}`,
      data: {
        token,
        password,
      },
    });

    if (token && password) {
      stillMounted && setLoading(true);
      InPlayerService.setNewPassword({
        password,
        token,
        brandingId,
      })
        .then(() => {
          logger.debug({
            message: `Set new password task succeed, password: ${password}, token: ${token}`,
            data: {
              password,
              token,
            },
          });

          showAlertToUser({
            title: screenLocalizations.reset_password_success_title,
            message: screenLocalizations.reset_password_success_text,
            type: "success",
          });
          stillMounted && setLoading(false);
          stillMounted && setScreen(ScreensData.LOGIN);
        })
        .catch((error) => {
          logger.error({
            message: `Set new password task failed, password: ${password}, token: ${token}`,
            data: {
              password,
              token,
              error,
            },
          });

          stillMounted && setLoading(false);

          showAlertToUser({
            title: screenLocalizations.reset_password_error_title,
            message: screenLocalizations.reset_password_error_text,
          });
        });
    } else {
      stillMounted && setScreen(ScreensData.FORGOT_PASSWORD);
    }
  };

  const forgotPasswordFlowCallback = ({ email }) => {
    Keyboard.dismiss();
    const {
      configuration: { in_player_client_id },
    } = props;

    logger.debug({
      message: `Request password change task, email: ${email}`,
      data: {
        email,
      },
    });

    if (email) {
      stillMounted && setLoading(true);
      InPlayerService.requestPassword({
        email,
        clientId: in_player_client_id,
        brandingId,
      })
        .then((result) => {
          const { message } = result;

          logger.debug({
            message: `Request password change task, email: ${email}`,
            data: {
              email,
            },
          });

          showAlertToUser({
            title: screenLocalizations.request_password_success_title,
            message,
            type: "success",
          });
          stillMounted && setLoading(false);
          stillMounted && setScreen(ScreensData.SET_NEW_PASSWORD);
        })
        .catch((error) => {
          logger.error({
            message: `Request password change task failed, email: ${email}`,
            data: {
              email,
              error,
            },
          });
          stillMounted && setLoading(false);
          showAlertToUser({
            title: screenLocalizations.request_password_error_title,
            message: screenLocalizations.request_password_error_text,
          });
          stillMounted && setScreen(ScreensData.LOGIN);
        });
    } else {
      stillMounted && setScreen(ScreensData.LOGIN);
    }
  };

  const onPresentForgotPasswordScreen = () => {
    stillMounted && setScreen(ScreensData.FORGOT_PASSWORD);
  };

  const renderAuthenticationScreen = () => {
    switch (screen) {
      case ScreensData.LOGIN:
        return (
          <Login
            initialEmail={lastEmailUsed}
            login={login}
            signUp={() => {
              stillMounted && setScreen(ScreensData.SIGN_UP);
            }}
            onPresentForgotPasswordScreen={onPresentForgotPasswordScreen}
            onLoginError={showAlertToUser}
            {...props}
          />
        );

      case ScreensData.SIGN_UP:
        return (
          <SignUp
            createAccount={createAccount}
            onBackButton={() => {
              stillMounted && setScreen(ScreensData.LOGIN);
            }}
            onSignUpError={showAlertToUser}
            {...props}
          />
        );
      case ScreensData.FORGOT_PASSWORD:
        return (
          <ForgotPassword
            forgotPasswordFlowCallback={forgotPasswordFlowCallback}
            onBackButton={() => {
              stillMounted && setScreen(ScreensData.LOGIN);
            }}
            onError={showAlertToUser}
            {...props}
          />
        );
      case ScreensData.SET_NEW_PASSWORD:
        return (
          <SetNewPassword
            setNewPasswordCallback={setNewPasswordCallback}
            onBackButton={() => {
              stillMounted && setScreen(ScreensData.FORGOT_PASSWORD);
            }}
            onError={showAlertToUser}
            {...props}
          />
        );
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
      {!Platform.isTV && !isWebBasedPlatform && (
        <DropdownAlert ref={(ref) => (this.dropDownAlertRef = ref)} />
      )}
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
