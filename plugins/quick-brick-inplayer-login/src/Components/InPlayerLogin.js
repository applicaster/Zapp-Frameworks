import React, { useState, useLayoutEffect } from "react";
// https://github.com/testshallpass/react-native-dropdownalert#usage
import DropdownAlert from "react-native-dropdownalert";
import { isWebBasedPlatform } from "../Utils/Platform";
import { showAlert } from "../Utils/Account";
import {
  AccountFlow,
  LogoutFlow,
} from "@applicaster/applicaster-account-components";
import * as R from "ramda";
import * as InPlayerService from "../Services/inPlayerService";
import { useNavigation } from "@applicaster/zapp-react-native-utils/reactHooks/navigation";
import { getLocalizations } from "../Utils/Localizations";
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

export const logger = createLogger({
  subsystem: BaseSubsystem,
  category: BaseCategories.GENERAL,
});

const getRiversProp = (key, rivers = {}) => {
  const getPropByKey = R.compose(
    R.prop(key),
    R.find(R.propEq("type", "quick-brick-inplayer")),
    R.values
  );

  return getPropByKey(rivers);
};

const localStorageTokenKey = "in_player_token";
const userAccountStorageTokenKey = "idToken";
const HookTypeData = {
  UNDEFINED: "Undefined",
  PLAYER_HOOK: "PlayerHook",
  SCREEN_HOOK: "ScreenHook",
  USER_ACCOUNT: "UserAccount",
};

function InPlayerLogin(props) {
  const navigator = useNavigation();
  const [parentLockWasPresented, setParentLockWasPresented] = useState(false);
  const [idToken, setIdtoken] = useState(null);
  const [hookType, setHookType] = useState(HookTypeData.UNDEFINED);
  const [loading, setLoading] = useState(true);
  const [lastEmailUsed, setLastEmailUsed] = useState(null);

  const { callback, payload, rivers } = props;
  const localizations = getRiversProp("localizations", rivers);
  const styles = getRiversProp("styles", rivers);

  const screenStyles = getStyles(styles);
  const screenLocalizations = getLocalizations(localizations);

  const {
    configuration: {
      in_player_client_id: clientId,
      in_player_referrer: referrer,
      in_player_branding_id,
      in_player_environment,
    },
  } = props;
  const brandingId = React.useMemo(() => {
    const parsedValue = parseInt(in_player_branding_id);
    return isNaN(parsedValue) ? null : parsedValue;
  }, []);

  const showParentLock =
    props?.configuration?.import_parent_lock === "1" ? true : false;

  let stillMounted = true;

  useLayoutEffect(() => {
    InPlayerSDK.tokenStorage.overrides = {
      setItem: async function (
        defaultTokenKey, // 'inplayer_token'
        tokenValue
      ) {
        console.log("NewTOKEN", { tokenValue });
        await localStorageSet(localStorageTokenKey, tokenValue);
        await localStorageSetUserAccount(
          userAccountStorageTokenKey,
          tokenValue
        );
      },
      getItem: async function () {
        const token = await localStorageGet(localStorageTokenKey);
        console.log("GetTOKEN", { token });
        return token;
      },
      removeItem: async function () {
        console.log("RemoveTOKEN");
        await localStorageRemove(localStorageTokenKey);
        await localStorageRemoveUserAccount(userAccountStorageTokenKey);
      },
    };

    setupEnvironment();
  }, []);

  function checkIfUserAuthenteficated() {
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
              showParentLock,
            });
            if (showParentLock) {
              eventMessage = `${eventMessage} not granted, present parent lock`;
            } else {
              eventMessage = `${eventMessage} not granted, present login screen`;
            }
          }
        }
        event.setMessage(eventMessage).send();
      })
      .finally(() => {
        stillMounted && setLoading(false);
      });
  }

  async function setupEnvironment() {
    await checkIfUserAuthenteficated();
    setLastEmailUsed((await InPlayerService.getLastEmailUsed()) || null);

    const token = await localStorageGet(localStorageTokenKey);
    setIdtoken(token);

    logger.debug({
      message: "Starting InPlayer Plugin",
      data: { configuration: props?.configuration },
    });

    setConfig(in_player_environment);

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
      if (authenticationRequired || assetId) {
        logger.debug({
          message: `Plugin hook_type: ${HookTypeData.PLAYER_HOOK}`,
          data: { ...logData, hook_type: HookTypeData.PLAYER_HOOK },
        });
        stillMounted && setHookType(HookTypeData.PLAYER_HOOK);
      } else {
        logger.debug({
          message:
            "Data source not support InPlayer plugin invocation, finishing hook with: success",
          data: { ...logData },
        });
        callback && callback({ success: true, error: null, payload });
      }
    } else {
      console.log({ isHook: !isHook(navigator), stillMounted });

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
        console.log("Here!2");
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

  async function accountFlowCallback({ success }) {
    let eventMessage = `Account Flow completion: success ${success}, hook_type: ${hookType}`;

    const event = logger
      .createEvent()
      .setLevel(XRayLogLevel.debug)
      .addData({ success, payload, hook_type: hookType });

    if (success) {
      const token = await localStorageGet(localStorageTokenKey);
      event.addData({ token });
    }

    if (hookType === HookTypeData.USER_ACCOUNT) {
      event.setMessage(`${eventMessage}, plugin finished task: go back`).send();
      navigator.goBack();
    } else {
      const { callback } = props;
      event.setMessage(`${eventMessage}, plugin finished task`).send();
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

      callback && callback({ success, error: null, payload: payload });
    }
  }

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
      email: email,
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
            email: trimmedEmail,
            password,
            fullName,
            error,
          },
        });
        stillMounted && setLoading(false);
      });
  }

  function onNewPasswordChange({ password, token }) {
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

  function onAccountError({ title, message, type = "warn" }) {
    showAlertToUser({ title, message, type });
  }

  function renderAccount() {
    console.log("renderAccount");
    return (
      <>
        <AccountFlow
          setParentLockWasPresented={setParentLockWasPresented}
          shouldShowParentLock={showParentLock}
          backButton={!isHomeScreen(navigator)}
          screenStyles={screenStyles}
          screenLocalizations={screenLocalizations}
          onLogin={onLogin}
          onCreateAccount={onCreateAccount}
          onNewPasswordChange={onNewPasswordChange}
          onForgotPassword={onForgotPassword}
          onError={onAccountError}
          loading={loading}
          lastEmailUsed={lastEmailUsed}
          {...props}
        />
        {!Platform.isTV && !isWebBasedPlatform && (
          <DropdownAlert ref={(ref) => (this.dropDownAlertRef = ref)} />
        )}
      </>
    );
  }

  const renderUACFlow = () => {
    return idToken ? renderLogoutScreen() : renderAccount();
  };

  const renderLogoutScreen = () => {
    return (
      <LogoutFlow
        screenStyles={screenStyles}
        screenLocalizations={screenLocalizations}
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
  console.log({ hookType });

  return renderFlow();
}
