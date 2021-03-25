import React, { useState, useEffect, useCallback } from "react";
import { Platform } from "react-native";
// https://github.com/testshallpass/react-native-dropdownalert#usage
import DropdownAlert from "react-native-dropdownalert";
import { isWebBasedPlatform } from "../../Utils/Platform";
import { showAlert } from "../../Utils/Account";
import AccountComponents from "@applicaster/applicaster-account-components";
import * as R from "ramda";
import { useNavigation } from "@applicaster/zapp-react-native-utils/reactHooks/navigation";
import { getLocalizations } from "../../Utils/Localizations";
import {
  getLastEmailUsed,
  signIn,
  signUp,
  getToken,
  signOut,
  requestPassword,
} from "../../Services/CleengMiddlewateService";
import { isAuthenticationRequired } from "../../Utils/PayloadUtils";

import { getStyles, isHomeScreen } from "../../Utils/Customization";
import { isHook } from "../../Utils/UserAccount";
import {
  createLogger,
  BaseSubsystem,
  BaseCategories,
  XRayLogLevel,
} from "../../Services/LoggerService";

const logger = createLogger({
  subsystem: BaseSubsystem,
  category: BaseCategories.GENERAL,
});

const getRiversProp = (key, rivers = {}) => {
  const getPropByKey = R.compose(
    R.prop(key),
    R.find(R.propEq("type", "zapp-cleeng-login")),
    R.values
  );

  return getPropByKey(rivers);
};

const localStorageTokenKey = "in_player_token";
const userAccountStorageTokenKey = "idToken";

const Login = (props) => {
  const HookTypeData = {
    UNDEFINED: "Undefined",
    PLAYER_HOOK: "PlayerHook",
    SCREEN_HOOK: "ScreenHook",
    USER_ACCOUNT: "UserAccount",
  };

  const navigator = useNavigation();
  const [parentLockWasPresented, setParentLockWasPresented] = useState(false);
  const [idToken, setIdtoken] = useState(null);
  const [hookType, setHookType] = useState(HookTypeData.UNDEFINED);
  const [loading, setLoading] = useState(true);
  const [lastEmailUsed, setLastEmailUsed] = useState(null);
  const [dropDownAlertRef, setDropDownAlertRef] = useState(null);
  const { callback, payload, rivers } = props;
  const localizations = getRiversProp("localizations", rivers);
  const styles = getRiversProp("styles", rivers);

  const screenStyles = getStyles(styles);
  const screenLocalizations = getLocalizations(localizations);

  const {
    configuration: { publisherId, logout_completion_action = "go_back" },
  } = props;

  const showParentLock = props?.configuration?.import_parent_lock;

  let stillMounted = true;

  useEffect(() => {
    navigator.hideNavBar();

    setupEnvironment();
    return () => {
      navigator.showNavBar();
    };
  }, []);

  async function setupEnvironment() {
    const token = await getToken();
    console.log({ token });
    setLastEmailUsed((await getLastEmailUsed()) || null);
    setIdtoken(token);

    logger.debug({
      message: "Starting Cleeng Login Plugin",
      data: { configuration: props?.configuration },
    });

    if (payload) {
      const authenticationRequired = true;
      // isAuthenticationRequired({ payload });

      const logData = {
        authentication_required: authenticationRequired,
        configuration: props?.configuration,
      };

      if (!token && authenticationRequired) {
        setLoading(false);

        logger.debug({
          message: `Plugin hook_type: ${HookTypeData.PLAYER_HOOK}`,
          data: {
            ...logData,
            hook_type: HookTypeData.PLAYER_HOOK,
            is_authenticated: !!token,
          },
        });
        stillMounted && setHookType(HookTypeData.PLAYER_HOOK);
      } else {
        logger.debug({
          message: "InPlayer plugin invocation, finishing hook with: success",
          data: { ...logData, is_authenticated: !!token },
        });
        callback && callback({ success: true, error: null, payload });
      }
    } else {
      setLoading(false);
      if (!isHook(navigator)) {
        logger.debug({
          message: `Plugin hook_type: ${HookTypeData.USER_ACCOUNT}`,
          data: {
            configuration: props?.configuration,
            hook_type: HookTypeData.USER_ACCOUNT,
          },
        });

        stillMounted && setHookType(HookTypeData.USER_ACCOUNT);
      } else {
        logger.debug({
          message: `Plugin hook_type: ${HookTypeData.SCREEN_HOOK}`,
          data: {
            configuration: props?.configuration,
            hook_type: HookTypeData.SCREEN_HOOK,
          },
        });

        stillMounted && setHookType(HookTypeData.SCREEN_HOOK);
      }
    }
    return () => {
      stillMounted = false;
    };
  }

  const accountFlowCallback = useCallback(
    async ({ success }) => {
      let eventMessage = `Account Flow completion: success ${success}, hook_type: ${hookType}`;

      const event = logger
        .createEvent()
        .setLevel(XRayLogLevel.debug)
        .addData({ success, payload, hook_type: hookType });

      if (success) {
        const token = await getToken();
        event.addData({ is_authenticated: !!token });
      }
      if (hookType === HookTypeData.USER_ACCOUNT) {
        event
          .setMessage(`${eventMessage}, plugin finished task: go back`)
          .send();
        navigator.goBack();
      } else {
        const { callback } = props;
        event.setMessage(`${eventMessage}, plugin finished task`).send();
        if (payload) {
          let newPayload = payload;
          if (newPayload.extensions) {
            newPayload.extensions = {
              ...payload.extensions,
              parentLockWasPresented,
            };
          } else {
            newPayload.extensions = {
              parentLockWasPresented,
            };
          }
        }
        callback && callback({ success, error: null, payload: payload });
      }
    },
    [hookType]
  );

  const onLogin = async ({ email, password }) => {
    stillMounted && setLoading(true);

    logger.debug({
      message: `Perform Login In task, email: ${email}, password: ${password}`,
      data: {
        email,
        password,
      },
    });

    signIn({
      email,
      password,
      publisherId,
    })
      .then((data) => {
        console.log({ data });
        logger.debug({
          message: `Login succeed, email: ${email}, password: ${password}`,
          data: {
            email,
            password,
          },
        });
        accountFlowCallback({ success: true });
      })
      .catch(maybeShowAlertToUser(screenLocalizations.login_title_error_text))
      .catch((error) => {
        logger.error({
          message: `Login failed, email: ${email}, password: ${password}`,
          data: {
            email,
            password,
            error,
          },
        });
        stillMounted && setLoading(false);
      });
  };

  function onCreateAccount({ fullName, email, password, setScreen }) {
    stillMounted && setLoading(true);

    logger.debug({
      message: `Perform Create Account task, email: ${email}, password: ${password}`,
      data: {
        email,
        password,
      },
    });

    signUp({
      email,
      password,
      publisherId,
    })
      .then(() => {
        logger.debug({
          message: `Account Creation succeed, email: ${email}, password: ${password}`,
          data: {
            email,
            password,
          },
        });
        accountFlowCallback({ success: true });
      })
      .catch(maybeShowAlertToUser(screenLocalizations.signup_title_error_text))
      .catch((error) => {
        logger.error({
          message: `Account Creation failed, email: ${email}, password: ${password}`,
          data: {
            email,
            password,
            fullName,
            error,
          },
        });
        stillMounted && setLoading(false);
      });
  }

  function onForgotPassword({ email, setScreen }) {
    logger.debug({
      message: `Request password change task, email: ${email}`,
      data: {
        email,
      },
    });

    if (email) {
      stillMounted && setLoading(true);
      requestPassword({
        email,
        publisherId,
      })
        .then((result) => {
          logger.debug({
            message: `Password request complete, email: ${email}`,
            data: {
              email,
            },
          });

          showAlertToUser({
            title: screenLocalizations.request_password_success_title,
            message: screenLocalizations.request_password_success_message,
            type: "success",
          });
          stillMounted && setLoading(false);
          stillMounted && setScreen(AccountComponents.ScreensData.LOGIN);
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
        });
    }
  }
  const showAlertToUser = useCallback(
    ({ title, message, type = "warn" }) => {
      logger.log({
        message: `Aller will be presented for user title: ${title}, message: ${message}, type: ${type}`,
        data: {
          title,
          message,
          type,
        },
      });

      if (Platform.isTV || isWebBasedPlatform) {
        showAlert(title, message);
      } else {
        dropDownAlertRef.alertWithType(type, title, message);
      }
    },
    [dropDownAlertRef]
  );

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

  const invokeLogoutCompleteAction = () => {
    if (logout_completion_action === "go_home") {
      navigator.goHome();
    } else {
      navigator.goBack();
    }
  };

  async function onLogout({ setError }) {
    const timeout = 1000;
    try {
      const didLogout = await signOut();
      if (!didLogout) {
        navigator.goBack();
      }
      setTimeout(() => {
        invokeLogoutCompleteAction();
      }, timeout);
    } catch (error) {
      setError(error);
      setTimeout(() => {
        invokeLogoutCompleteAction();
      }, timeout);
    }
  }

  function onAccountError({ title, message, type = "warn" }) {
    showAlertToUser({ title, message, type });
  }

  function onAccountHandleBackButton() {
    accountFlowCallback({ success: false });
  }

  console.log({
    loading,
    AccountComponents,
    showBack: !isHomeScreen(navigator),
  });
  function renderAccount() {
    return (
      <>
        <AccountComponents.AccountFlow
          signUpScreen={{
            nameLabelDisabled: true,
          }}
          setParentLockWasPresented={setParentLockWasPresented}
          shouldShowParentLock={showParentLock}
          backButton={!isHomeScreen(navigator)}
          screenStyles={screenStyles}
          screenLocalizations={screenLocalizations}
          onLogin={onLogin}
          onCreateAccount={onCreateAccount}
          onForgotPassword={onForgotPassword}
          onError={onAccountError}
          onHandleBackButton={onAccountHandleBackButton}
          lastEmailUsed={lastEmailUsed}
          {...props}
        />
        {!Platform.isTV && !isWebBasedPlatform && (
          <DropdownAlert ref={(ref) => setDropDownAlertRef(ref)} />
        )}
        {loading && <AccountComponents.LoadingScreen />}
      </>
    );
  }

  const renderUACFlow = () => {
    return idToken ? renderLogoutScreen() : renderAccount();
  };

  const renderLogoutScreen = () => {
    return (
      <AccountComponents.LogoutFlow
        screenStyles={screenStyles}
        screenLocalizations={screenLocalizations}
        onLogout={onLogout}
        {...props}
      />
    );
  };

  function renderFlow() {
    switch (hookType) {
      case HookTypeData.PLAYER_HOOK || HookTypeData.SCREEN_HOOK:
        return renderAccount();
      case HookTypeData.USER_ACCOUNT:
        return renderUACFlow();
      case HookTypeData.UNDEFINED:
        return null;
    }
  }

  return renderFlow();
};
export default Login;
