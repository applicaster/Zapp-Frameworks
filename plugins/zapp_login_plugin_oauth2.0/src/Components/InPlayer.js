import React, { useState, useLayoutEffect } from "react";

import AccountFlow from "./AccountFlow";
import AssetFlow from "./AssetFlow";
import LogoutFlow from "./LogoutFlow";
import * as R from "ramda";

import { useNavigation } from "@applicaster/zapp-react-native-utils/reactHooks/navigation";
import { localStorage as defaultStorage } from "@applicaster/zapp-react-native-bridge/ZappStorage/LocalStorage";
import { initFromNativeLocalStorage } from "../LocalStorageHack";
import { getLocalizations } from "../Utils/Localizations";
import {
  isVideoEntry,
  inPlayerAssetId,
  isAuthenticationRequired,
} from "../Utils/PayloadUtils";
import { showAlert } from "../Utils/Account";
import { setConfig } from "../Services/inPlayerService";
import {
  getStyles,
  isHomeScreen,
  getMessageOrDefault,
} from "../Utils/Customization";
import { isHook, isTokenInStorage } from "../Utils/UserAccount";
import {
  createLogger,
  BaseSubsystem,
  BaseCategories,
  XRayLogLevel,
  addContext,
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
}

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
  const [isUserAuthenticated, setIsUserAuthenticated] = useState(false);

  const { callback, payload, rivers } = props;
  const localizations = getRiversProp('localizations', rivers);
  const styles = getRiversProp('styles', rivers);

  const screenStyles = getStyles(styles);
  const screenLocalizations = getLocalizations(localizations);

  const { import_parent_lock: showParentLock } = screenStyles;

  let stillMounted = true;

  useLayoutEffect(() => {
    setupEnvironment();
  }, []);

  const checkIdToken = async () => {
    await initFromNativeLocalStorage();
    const token = await isTokenInStorage("idToken");

    logger
      .createEvent()
      .setLevel(XRayLogLevel.debug)
      .setMessage(`User token is in local storage: ${token}`)
      .addData({ token_exists: token })
      .send();

    setIdtoken(token);
  };

  const setupEnvironment = async () => {
    const {
      configuration: { in_player_environment },
    } = props;
    addContext({ configuration: props.configuration, payload });

    logger
      .createEvent()
      .setLevel(XRayLogLevel.debug)
      .setMessage(`Starting InPlayer Plugin`)
      .addData({ in_player_environment })
      .send();

    await checkIdToken();

    setConfig(in_player_environment);

    const videoEntry = isVideoEntry(payload);
    let event = logger.createEvent().setLevel(XRayLogLevel.debug);

    if (videoEntry) {
      const authenticationRequired = isAuthenticationRequired({ payload });
      const assetId = inPlayerAssetId({
        payload,
        configuration: props.configuration,
      });

      event.addData({
        authentication_required: authenticationRequired,
        inplayer_asset_id: assetId,
        is_video_entry: videoEntry,
      });
      if (authenticationRequired || assetId) {
        event
          .setMessage(`Plugin hook_type: ${HookTypeData.PLAYER_HOOK}`)
          .addData({
            hook_type: HookTypeData.PLAYER_HOOK,
          })
          .send();
        stillMounted && setHookType(HookTypeData.PLAYER_HOOK);
      } else {
        event
          .setMessage(
            "Data source not support InPlayer plugin invocation, finishing hook with: success"
          )
          .send();
        callback && callback({ success: true, error: null, payload });
      }
    } else {
      if (!isHook(navigator)) {
        event
          .setMessage(`Plugin hook_type: ${HookTypeData.USER_ACCOUNT}`)
          .addData({
            hook_type: HookTypeData.USER_ACCOUNT,
          })
          .send();
        stillMounted && setHookType(HookTypeData.USER_ACCOUNT);
      } else {
        event
          .setMessage(`Plugin hook_type: ${HookTypeData.SCREEN_HOOK}`)
          .addData({
            hook_type: HookTypeData.SCREEN_HOOK,
          })
          .send();
        stillMounted && setHookType(HookTypeData.SCREEN_HOOK);
      }
    }
    return () => {
      stillMounted = false;
    };
  };

  const assetFlowCallback = ({ success, payload, error }) => {
    let eventMessage = `Asset Flow completion: success ${success}`;
    const event = logger
      .createEvent()
      .setLevel(XRayLogLevel.debug)
      .addData({ payload, success });

    if (error) {
      const message = getMessageOrDefault(error, screenLocalizations);
      event
        .addData({ message })
        .attachError(error)
        .setLevel(XRayLogLevel.error);
      eventMessage = `${eventMessage} error:${message}`;
      showAlert("General Error!", message);
    }

    event.setMessage(eventMessage).send();

    callback &&
      callback({
        success,
        error,
        payload,
      });
  };

  const accountFlowCallback = async ({ success }) => {
    let eventMessage = `Account Flow completion: success ${success}, hook_type: ${hookType}`;

    const event = logger
      .createEvent()
      .setLevel(XRayLogLevel.debug)
      .addData({ success, payload, hook_type: hookType });

    if (success) {
      const token = localStorage.getItem("inplayer_token");
      event.addData({ token });
      await defaultStorage.setItem("idToken", token);
    }

    if (hookType === HookTypeData.SCREEN_HOOK && success) {
      const { callback } = props;
      event.setMessage(`${eventMessage}, plugin finished task`).send();
      callback && callback({ success, error: null, payload: payload });
    } else if (hookType === HookTypeData.PLAYER_HOOK) {
      if (success) {
        event.setMessage(`${eventMessage}, next: Asset Flow`).send();
        stillMounted && setIsUserAuthenticated(true);
      } else {
        event.setMessage(`${eventMessage}, plugin finished task`).send();
        callback && callback({ success, error: null, payload: payload });
      }
    } else if (hookType === HookTypeData.USER_ACCOUNT) {
      event.setMessage(`${eventMessage}, plugin finished task: go back`).send();
      navigator.goBack();
    } else {
      event.setMessage(`${eventMessage}, plugin finished task`).send();

      callback && callback({ success: success, error: null, payload: payload });
    }
  };

  const renderPlayerHook = () => {
    return isUserAuthenticated ? (
      <AssetFlow
        setParentLockWasPresented={setParentLockWasPresented}
        parentLockWasPresented={parentLockWasPresented}
        shouldShowParentLock={shouldShowParentLock}
        assetFlowCallback={assetFlowCallback}
        screenStyles={screenStyles}
        screenLocalizations={screenLocalizations}
        {...props}
      />
    ) : (
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

  const renderScreenHook = () => {
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
    return <LogoutFlow screenStyles={screenStyles} screenLocalizations={screenLocalizations} {...props} />;
  };

  const renderUACFlow = () => {
    return idToken ? renderLogoutScreen() : renderScreenHook();
  };

  const shouldShowParentLock = (parentLockWasPresented) => !(parentLockWasPresented || !showParentLock);

  const renderFlow = () => {
    switch (hookType) {
      case HookTypeData.PLAYER_HOOK:
        return renderPlayerHook();
      case HookTypeData.SCREEN_HOOK:
        return renderScreenHook();
      case HookTypeData.USER_ACCOUNT:
        return renderUACFlow();
      case HookTypeData.UNDEFINED:
        return null;
    }
  };

  return renderFlow();
};

export default InPlayer;
