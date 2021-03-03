import React, { useState, useLayoutEffect } from "react";

import { assetLoader } from "./AssetLoader";
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
import LoadingScreen from "./LoadingScreen";
import { showAlert } from "../Utils/Account";
import { setConfig, isAuthenticated } from "../Services/inPlayerService";
import {
  getStyles,
  isHomeScreen,
  getMessageOrDefault,
} from "../Utils/Customization";
import { isHook } from "../Utils/UserAccount";
import {
  createLogger,
  BaseSubsystem,
  BaseCategories,
  XRayLogLevel,
  addContext,
} from "../Services/LoggerService";
import { useSelector } from "react-redux";

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
  const { store } = useSelector(R.prop("appData"));

  const HookTypeData = {
    UNDEFINED: "Undefined",
    PLAYER_HOOK: "PlayerHook",
  };

  const navigator = useNavigation();
  const [parentLockWasPresented, setParentLockWasPresented] = useState(false);
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
      payload,
      configuration: { in_player_environment, in_player_client_id },
    } = props;
    const isUserAuthenticated = await isAuthenticated(in_player_client_id);

    logger
      .createEvent()
      .setLevel(XRayLogLevel.debug)
      .setMessage(`Starting InPlayer Plugin`)
      .addData({ in_player_environment })
      .send();

    setConfig(in_player_environment);

    let event = logger.createEvent().setLevel(XRayLogLevel.debug);
    // Add try catch
    if (payload) {
      const assetId = await inPlayerAssetId({
        payload,
        configuration: props.configuration,
      });

      const authenticationRequired = isAuthenticationRequired({ payload });
      console.log("Before", { assetId, authenticationRequired });
      event.addData({
        inplayer_asset_id: assetId,
      });
      console.log({
        isUserAuthenticated,
        assetId,
        payload,
        props,
        configuration: props.configuration,
      });
      console.log({ authenticationRequired, isUserAuthenticated, assetId });
      if (authenticationRequired && isUserAuthenticated && assetId) {
        const result = await assetLoader({ props, assetId, store });
        console.log("assetLoader", { result });
        //callback && callback({ success: !!result, error: null, payload });
      } else {
        event
          .setMessage(
            "Data source not support InPlayer plugin invocation, finishing hook with: success"
          )
          .send();
        callback && callback({ success: true, error: null, payload });
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
      event.addData({ message, error }).setLevel(XRayLogLevel.error);
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

  const renderPlayerHook = () => {
    console.log("REnderPlayer hhook");
    return (
      <AssetLoader
        setParentLockWasPresented={setParentLockWasPresented}
        parentLockWasPresented={parentLockWasPresented}
        shouldShowParentLock={shouldShowParentLock}
        assetFlowCallback={assetFlowCallback}
        screenStyles={screenStyles}
        screenLocalizations={screenLocalizations}
        {...props}
      />
    );
  };

  const shouldShowParentLock = (parentLockWasPresented) =>
    !(parentLockWasPresented || !showParentLock);

  const renderFlow = () => {
    switch (hookType) {
      case HookTypeData.PLAYER_HOOK:
        return renderPlayerHook();
      case HookTypeData.UNDEFINED:
        return null;
    }
  };

  return <LoadingScreen />;
};

export default InPlayer;
