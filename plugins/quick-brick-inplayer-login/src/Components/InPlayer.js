import React, { useState, useLayoutEffect } from "react";

import AccountFlow from "./AccountFlow";
import LogoutFlow from "./LogoutFlow";
import * as R from "ramda";

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

const InPlayer = (props) => {
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

  const { callback, payload, rivers } = props;
  const localizations = getRiversProp("localizations", rivers);
  const styles = getRiversProp("styles", rivers);

  const screenStyles = getStyles(styles);
  const screenLocalizations = getLocalizations(localizations);

  const { import_parent_lock: showParentLock } = screenStyles;

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

  const setupEnvironment = async () => {
    const {
      configuration: { in_player_environment },
    } = props;
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
        if (token) {
          console.log({ success: true, error: null, payload });
          logger.debug({
            message: "User authenteficated, finishing hook with: success",
            data: { ...logData },
          });
          callback && callback({ success: true, error: null, payload });
        } else {
          logger.debug({
            message: `Plugin hook_type: ${HookTypeData.PLAYER_HOOK}`,
            data: { ...logData, hook_type: HookTypeData.PLAYER_HOOK },
          });
          stillMounted && setHookType(HookTypeData.PLAYER_HOOK);
        }
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
  };

  const accountFlowCallback = async ({ success }) => {
    let eventMessage = `Account Flow completion: success ${success}, hook_type: ${hookType}`;

    const event = logger
      .createEvent()
      .setLevel(XRayLogLevel.debug)
      .addData({ success, payload, hook_type: hookType });

    if (success) {
      const token = await localStorageGet(localStorageTokenKey);
      event.addData({ token });
    }

    if (
      (hookType === HookTypeData.SCREEN_HOOK ||
        hookType === HookTypeData.PLAYER_HOOK) &&
      success
    ) {
      const { callback } = props;
      event.setMessage(`${eventMessage}, plugin finished task`).send();
      callback && callback({ success, error: null, payload: payload });
    } else if (hookType === HookTypeData.USER_ACCOUNT) {
      event.setMessage(`${eventMessage}, plugin finished task: go back`).send();
      navigator.goBack();
    } else {
      event.setMessage(`${eventMessage}, plugin finished task`).send();

      callback && callback({ success: success, error: null, payload: payload });
    }
  };

  const renderAccount = () => {
    console.log("renderAccount");
    return (
      <AccountFlow
        setParentLockWasPresented={setParentLockWasPresented}
        parentLockWasPresented={parentLockWasPresented}
        shouldShowParentLock={shouldShowParentLock}
        accountFlowCallback={accountFlowCallback}
        backButton={!isHomeScreen(navigator)}
        screenStyles={screenStyles}
        screenLocalizations={screenLocalizations}
        {...props}
      />
    );
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

  const renderUACFlow = () => {
    return idToken ? renderLogoutScreen() : renderScreenHook();
  };

  const shouldShowParentLock = (parentLockWasPresented) =>
    !(parentLockWasPresented || !showParentLock);

  const renderFlow = () => {
    switch (hookType) {
      case HookTypeData.PLAYER_HOOK || HookTypeData.SCREEN_HOOK:
        return renderAccount();
      case HookTypeData.USER_ACCOUNT:
        return renderUACFlow();
      case HookTypeData.UNDEFINED:
        return null;
    }
  };
  console.log({ hookType });

  return renderFlow();
};

export default InPlayer;
