import React, { useState, useEffect, useCallback, useMemo } from "react";
import { Platform, View } from "react-native";
// https://github.com/testshallpass/react-native-dropdownalert#usage
import DropdownAlert from "react-native-dropdownalert";
import { isWebBasedPlatform } from "../Utils/Platform";
import { showAlert } from "../Utils/Account";
import AccountComponents from "@applicaster/applicaster-account-components";
import * as R from "ramda";
import * as InPlayerService from "../Services/inPlayerService";
import { useNavigation } from "@applicaster/zapp-react-native-utils/reactHooks/navigation";
import { getLocalizations } from "../Utils/Localizations";
import {
  updatePresentedInfo,
  screenShouldBePresented,
  removePresentedInfo,
} from "../Utils/PresentOnce";
import {
  localStorageGet,
  localStorageSet,
  localStorageRemove,
  localStorageSetUserAccount,
  localStorageRemoveUserAccount,
} from "../Services/LocalStorageService";

import {
  inPlayerAssetId,
  isAuthenticationRequired,
} from "../Utils/PayloadUtils";
import InPlayerSDK from "@inplayer-org/inplayer.js";

import { setConfig } from "../Services/inPlayerService";
import { getStyles, isHomeScreen } from "../Utils/Customization";
import { isHook } from "../Utils/UserAccount";
import {
  createLogger,
  BaseSubsystem,
  BaseCategories,
  XRayLogLevel,
} from "../Services/LoggerService";

const logger = createLogger({
  subsystem: BaseSubsystem,
  category: BaseCategories.GENERAL,
});

const getRiversProp = (key, rivers = {}, screenId = "") => {
  const getPropByKey = R.compose(
    R.prop(key),
    R.find(R.propEq("id", screenId)),
    R.values
  );

  return getPropByKey(rivers);
};

const localStorageTokenKey = "in_player_token";
const userAccountStorageTokenKey = "idToken";

const InPlayerLogin = (props) => {
  const HookTypeData = {
    UNDEFINED: "Undefined",
    PLAYER_HOOK: "PlayerHook",
    SCREEN_HOOK: "ScreenHook",
    USER_ACCOUNT: "UserAccount",
  };
  const navigator = useNavigation();
  const screenId = navigator?.activeRiver?.id;
  const [parentLockWasPresented, setParentLockWasPresented] = useState(false);
  const [idToken, setIdtoken] = useState(null);
  const [hookType, setHookType] = useState(HookTypeData.UNDEFINED);
  const [loading, setLoading] = useState(true);
  const [lastEmailUsed, setLastEmailUsed] = useState(null);
  const { callback, payload, rivers } = props;

  const localizations = getRiversProp("localizations", rivers, screenId);
  const styles = getRiversProp("styles", rivers, screenId);
  const general = getRiversProp("general", rivers, screenId);

  const screenStyles = useMemo(() => getStyles(styles), [styles]);

  const screenLocalizations = getLocalizations(localizations);
  const show_hook_once = general?.show_hook_once || false;
  const payloadIsScreen = payload?.type;

  const {
    configuration: {
      in_player_client_id: clientId,
      in_player_referrer: referrer,
      in_player_branding_id,
      in_player_environment,
      logout_completion_action = "go_back",
    },
  } = props;
  const brandingId = React.useMemo(() => {
    const parsedValue = parseInt(in_player_branding_id);
    return isNaN(parsedValue) ? null : parsedValue;
  }, []);
  let showParentLock =
    (screenStyles?.import_parent_lock === "1" ||
      screenStyles?.import_parent_lock === true) &&
    props?.payload?.extensions?.skip_parent_lock !== true
      ? true
      : false;

  navigator.hideNavBar();
  navigator.hideBottomBar();
  let stillMounted = true;
  useEffect(() => {
    setupEnvironment();
    return () => {
      navigator.showNavBar();
      navigator.showBottomBar();
      stillMounted = false;
    };
  }, []);

  async function checkIfUserAuthenteficated() {
    return InPlayerService.isAuthenticated(clientId).then(
      async (isAuthenticated) => {
        let eventMessage = "Account Flow:";
        const event = logger
          .createEvent()
          .setLevel(XRayLogLevel.debug)
          .addData({ is_authenticated: isAuthenticated });

        if (stillMounted) {
          if (isAuthenticated) {
            eventMessage = `${eventMessage} access granted, flow completed`;
            return true;
          } else {
            if (showParentLock) {
              eventMessage = `${eventMessage} not granted, present parent lock`;
            } else {
              eventMessage = `${eventMessage} not granted, present login screen`;
            }
          }
        }
        event.setMessage(eventMessage).send();
        return false;
      }
    );
  }

  async function setupEnvironment() {
    await setConfig(in_player_environment);

    InPlayerSDK.tokenStorage.overrides = {
      setItem: async function (
        defaultTokenKey, // 'inplayer_token'
        tokenValue
      ) {
        await localStorageSet(localStorageTokenKey, tokenValue);
        await localStorageSetUserAccount(
          userAccountStorageTokenKey,
          tokenValue
        );
      },
      getItem: async function () {
        const token = await localStorageGet(localStorageTokenKey);
        return token;
      },
      removeItem: async function () {
        await localStorageRemove(localStorageTokenKey);
        await localStorageRemoveUserAccount(userAccountStorageTokenKey);
      },
    };

    setLastEmailUsed((await InPlayerService.getLastEmailUsed()) || null);

    const { token } = await InPlayerSDK.Account.getToken();
    setIdtoken(token);

    logger.debug({
      message: "Starting InPlayer Plugin",
      data: { configuration: props?.configuration },
    });
    let shouldBeSkipped = payload?.extensions?.skip_hook;
    console.log({ shouldBeSkipped, payload });

    if (show_hook_once) {
      const presentScreen = await screenShouldBePresented();
      if (presentScreen === false) {
        shouldBeSkipped = true;
      } else {
        await removePresentedInfo();
      }
    }

    if (shouldBeSkipped) {
      logger.debug({
        message:
          "InPlayer plugin invocation, finishing hook with: success. Hook should be scipped",
        data: { should_be_skipped: shouldBeSkipped },
      });
      accountFlowCallback({ success: true });
      return;
    }

    if (payload) {
      const authenticationRequired = isAuthenticationRequired({ payload });
      const assetId = inPlayerAssetId({
        payload,
        configuration: props.configuration,
      });
      const logData = {
        authentication_required: authenticationRequired,
        inplayer_asset_id: assetId,
        configuration: props?.configuration,
      };
      const isAuthenticated = await checkIfUserAuthenteficated();
      if (!isAuthenticated && (authenticationRequired || assetId)) {
        logger.debug({
          message: `Plugin hook_type: ${HookTypeData.PLAYER_HOOK}`,
          data: {
            ...logData,
            hook_type: HookTypeData.PLAYER_HOOK,
            isAuthenticated,
          },
        });
        stillMounted && setLoading(false);

        stillMounted && setHookType(HookTypeData.PLAYER_HOOK);
      } else {
        logger.debug({
          message: "InPlayer plugin invocation, finishing hook with: success",
          data: { ...logData, isAuthenticated },
        });
        accountFlowCallback({ success: true });
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
  }

  const accountFlowCallback = useCallback(
    async ({ success }) => {
      if (show_hook_once) {
        updatePresentedInfo();
      }
      let eventMessage = `Account Flow completion: success ${success}, hook_type: ${hookType}`;

      const event = logger
        .createEvent()
        .setLevel(XRayLogLevel.debug)
        .addData({ success, payload, hook_type: hookType });

      if (success) {
        const token = await localStorageGet(localStorageTokenKey);
        event.addData({ token });
      }
      console.log({ hookType });
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
          callback && callback({ success, error: null, payload: newPayload });
        } else {
          callback && callback({ success, error: null, payload });
        }
      }
    },
    [hookType, parentLockWasPresented]
  );

  const onLogin = ({ email, password }) => {
    stillMounted && setLoading(true);

    logger.debug({
      message: `Perform Login In task, email: ${email}, password: ${password}`,
      data: {
        email,
        password,
      },
    });

    InPlayerService.login({
      email,
      password,
      clientId,
      referrer,
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

    InPlayerService.signUp({
      fullName,
      email,
      password,
      clientId,
      referrer,
      brandingId,
      setScreen,
    })
      .then(() => {
        logger.debug({
          message: `Account Creation succeed, fullName: ${fullName}, email: ${email}, password: ${password}`,
          data: {
            email,
            password,
            fullName,
          },
        });
        accountFlowCallback({ success: true });
      })
      .catch(maybeShowAlertToUser(screenLocalizations.signup_title_error_text))
      .catch((error) => {
        logger.error({
          message: `Account Creation failed, fullName: ${fullName}, email: ${email}, password: ${password}`,
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

  function onNewPasswordChange({ password, token, setScreen }) {
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
          stillMounted && setScreen(AccountComponents.ScreensData.LOGIN);
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
      stillMounted && setScreen(AccountComponents.ScreensData.FORGOT_PASSWORD);
    }
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
      InPlayerService.requestPassword({
        email,
        clientId,
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
          stillMounted &&
            setScreen(AccountComponents.ScreensData.SET_NEW_PASSWORD);
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
          stillMounted && setScreen(AccountComponents.ScreensData.LOGIN);
        });
    } else {
      stillMounted && setScreen(AccountComponents.ScreensData.LOGIN);
    }
  }

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
      : this.dropDownAlertRef?.alertWithType(type, title, message);
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
      const didLogout = await InPlayerService.signOut();
      if (!didLogout) {
        navigator.goBack();
      }
      setTimeout(() => {
        invokeLogoutCompleteAction();
      }, timeout);
    } catch (error) {
      setError(error);
      setTimeout(() => {
        invokeCompleteAction();
      }, timeout);
    }
  }

  function onAccountError({ title, message, type = "warn" }) {
    showAlertToUser({ title, message, type });
  }
  function onAccountHandleBackButton() {
    if (payloadIsScreen) {
      accountFlowCallback({ success: true });
    } else {
      accountFlowCallback({ success: false });
    }
  }

  function renderAccount() {
    return (
      <View
        style={{ flex: 1, backgroundColor: screenStyles?.background_color }}
      >
        <AccountComponents.AccountFlow
          setParentLockWasPresented={setParentLockWasPresented}
          shouldShowParentLock={showParentLock}
          backButton={!isHomeScreen(navigator) || payloadIsScreen}
          screenStyles={screenStyles}
          screenLocalizations={screenLocalizations}
          onLogin={onLogin}
          onCreateAccount={onCreateAccount}
          onNewPasswordChange={onNewPasswordChange}
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
          <DropdownAlert ref={(ref) => (this.dropDownAlertRef = ref)} />
        )}
      </View>
    );
  }

  return renderFlow();
};
export default InPlayerLogin;
