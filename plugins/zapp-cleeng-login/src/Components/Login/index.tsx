import React, { useState, useEffect, useCallback } from "react";
import { Platform, View } from "react-native";
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
  prepareMiddleware,
  extendToken,
} from "../../Services/CleengMiddlewareService";
import { isAuthenticationRequired } from "../../Utils/PayloadUtils";

import { getStyles, isHomeScreen } from "../../Utils/Customization";
import { isHook } from "../../Utils/UserAccount";
import {
  createLogger,
  BaseSubsystem,
  BaseCategories,
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
  const showParentLock =
    screenStyles?.import_parent_lock === "1" ? true : false;
  let stillMounted = true;

  useEffect(() => {
    navigator.hideNavBar();

    setupEnvironment();
    return () => {
      navigator.showNavBar();
    };
  }, []);

  useEffect(() => {
    if (hookType === HookTypeData.USER_ACCOUNT && idToken) {
      onLogout();
    }
  }, [hookType, idToken]);
  async function setupEnvironment() {
    prepareMiddleware(props?.configuration);
    const oldToken = await getToken();
    const newToken = await extendToken({ token: oldToken, publisherId });
    setLastEmailUsed((await getLastEmailUsed()) || null);
    setIdtoken(newToken);

    logger.debug({
      message: "Starting Cleeng Login Plugin",
      data: { configuration: props?.configuration },
    });

    if (payload) {
      const testEnvironmentEnabled =
        props?.configuration?.force_authentication_on_all || "off";
      const authenticationRequired =
        testEnvironmentEnabled === "on" || isAuthenticationRequired(payload);
      const logData = {
        authentication_required: authenticationRequired,
        configuration: props?.configuration,
      };

      if (!newToken && authenticationRequired) {
        logger.debug({
          message: `Plugin hook_type: ${HookTypeData.PLAYER_HOOK}`,
          data: {
            ...logData,
            hook_type: HookTypeData.PLAYER_HOOK,
            is_authenticated: !!newToken,
          },
        });
        stillMounted && setHookType(HookTypeData.PLAYER_HOOK);
        setLoading(false);
      } else {
        logger.debug({
          message: "Cleeng plugin invocation, finishing hook with: success",
          data: { ...logData, is_authenticated: !!newToken },
        });
        callback && callback({ success: true, error: null, payload });
      }
    } else {
      if (!isHook(navigator)) {
        setLoading(false);

        logger.debug({
          message: `Plugin hook_type: ${HookTypeData.USER_ACCOUNT}`,
          data: {
            configuration: props?.configuration,
            hook_type: HookTypeData.USER_ACCOUNT,
          },
        });

        stillMounted && setHookType(HookTypeData.USER_ACCOUNT);
      } else {
        setLoading(false);

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

      let data = { success, payload, hook_type: hookType };

      if (success) {
        const token = await getToken();
        data["is_authenticated"] = !!token;
      }
      if (hookType === HookTypeData.USER_ACCOUNT) {
        logger.debug({
          message: `${eventMessage}, plugin finished task: go back`,
          data: data,
        });

        navigator.goBack();
      } else {
        const { callback } = props;
        logger.debug({
          message: `${eventMessage}, plugin finished task`,
          data: data,
        });
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
      .then(() => {
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
        .then(() => {
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

  const onLogout = useCallback(async () => {
    setLoading(true);
    const timeout = 400;
    try {
      const didLogout = await signOut();

      dropDownAlertRef.alertWithType(
        "success",
        "",
        screenLocalizations?.logout_title_succeed_text
      );
      if (!didLogout) {
        navigator.goBack();
      }
      setTimeout(() => {
        invokeLogoutCompleteAction();
      }, timeout);
    } catch (error) {
      dropDownAlertRef.alertWithType(
        "error",
        screenStyles?.logout_title_fail_text,
        ""
      );

      setTimeout(() => {
        invokeLogoutCompleteAction();
      }, timeout);
    }
  }, [dropDownAlertRef]);

  function onAccountError({ title, message, type = "warn" }) {
    showAlertToUser({ title, message, type });
  }

  function onAccountHandleBackButton() {
    accountFlowCallback({ success: false });
  }

  function renderAccount() {
    return (
      <View
        style={{ flex: 1, backgroundColor: screenStyles?.background_color }}
      >
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
      </View>
    );
  }

  const renderUACFlow = () => {
    return idToken ? null : renderAccount();
  };

  function renderScreen() {
    switch (hookType) {
      case HookTypeData.PLAYER_HOOK || HookTypeData.SCREEN_HOOK:
        return renderAccount();
      case HookTypeData.USER_ACCOUNT:
        return renderUACFlow();
      case HookTypeData.UNDEFINED:
        return null;
    }
  }

  function renderFlow() {
    return (
      <View
        style={{
          flex: 1,
          backgroundColor: screenStyles?.background_color,
        }}
      >
        {renderScreen()}
        {loading && <AccountComponents.LoadingScreen />}

        {!Platform.isTV && !isWebBasedPlatform && (
          <DropdownAlert ref={(ref) => setDropDownAlertRef(ref)} />
        )}
      </View>
    );
  }

  return renderFlow();
};
export default Login;
