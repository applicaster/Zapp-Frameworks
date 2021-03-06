// @flow
import React, { useState, useEffect, useRef, useMemo } from "react";
import { useNavigation } from "@applicaster/zapp-react-native-utils/reactHooks/navigation";

import IntroScreen from "../IntroScreen";
import SignInScreen from "../SignInScreen";
import LogoutScreen from "../LogoutScreen";
import LoadingScreen from "../LoadingScreen";
import XRayLogger from "@applicaster/quick-brick-xray";
import {
  ScreenData,
  getRiversProp,
  isLoginRequired,
  isPlayerHook,
  showAlert,
  refreshToken,
} from "./utils";
import { BaseSubsystem, BaseCategories } from "../../Services/LoggerService";
import { getStyles } from "../../Utils/Customization";
import { getLocalizations } from "../../Utils/Localizations";

const logger = new XRayLogger(BaseCategories.GENERAL, BaseSubsystem);
console.disableYellowBox = true;

export const OAuth = (props) => {
  const navigator = useNavigation();
  const [screen, setScreen] = useState(ScreenData.LOADING);
  const [forceFocus, setForceFocus] = useState(false);
  const { callback, payload, rivers } = props;
  const screenId = navigator?.activeRiver?.id;

  const localizations = getRiversProp("localizations", rivers, screenId);
  const styles = getRiversProp("styles", rivers, screenId);
  const general = getRiversProp("general", rivers, screenId);
  const configuration = props?.configuration;

  const screenStyles = useMemo(() => getStyles(styles), [styles]);
  const screenLocalizations = getLocalizations(localizations);
  const mounted = useRef(true);
  const isPrehook = !!props?.callback;

  useEffect(() => {
    mounted.current = true;

    setupEnvironment();
    return () => {
      mounted.current = false;
    };
  }, []);

  async function setupEnvironment() {
    try {
      const playerHook = isPlayerHook(props?.payload);
      const testEnvironmentEnabled =
        props?.configuration?.force_authentication_on_all || "off";

      if (
        playerHook === true &&
        testEnvironmentEnabled === "off" &&
        isAuthenticationRequired(payload) === false
      ) {
        logger.debug({
          message: `setupEnvironment: Hook finished, no authentefication required, skipping`,
        });
        mounted.current &&
          callback &&
          callback({
            success: true,
            error: null,
            payload,
          });
        return;
      }
      const userNeedsToLogin = await isLoginRequired();
      if (userNeedsToLogin) {
        logger.debug({
          message: "setupEnvironment: Presenting login screen",
          data: { userNeedsToLogin },
        });
        if (playerHook) {
          mounted.current && setScreen(ScreenData.LOG_IN);
        } else {
          mounted.current && setScreen(ScreenData.INTRO);
        }
      } else {
        const success = await refreshToken(configuration);
        logger.debug({
          message: `setupEnvironment: Hook finished, refresh Token completed: ${success}`,
          data: { userNeedsToLogin, success },
        });

        if (success) {
          if (isPrehook) {
            mounted.current &&
              callback &&
              callback({ success: true, error: null, payload });
          } else {
            mounted.current && setScreen(ScreenData.LOG_OUT);
          }
        } else {
          // await removeDataFromStorages();

          if (playerHook) {
            mounted.current && setScreen(ScreenData.LOG_IN);
          } else {
            mounted.current && setScreen(ScreenData.INTRO);
          }
        }
      }
    } catch (error) {
      logger.error({
        message: `setupEnvironment: Error, ${error?.message}`,
        data: { error },
      });
      mounted.current && setScreen(ScreenData.INTRO);

      showAlert(
        screenLocalizations?.general_error_title,
        screenLocalizations?.general_error_message
      );
    }
  }

  function goToScreen(screen, forceFocus, changeFocus) {
    if (!changeFocus) {
      setScreen(screen);
      setForceFocus(forceFocus);
    } else {
      setForceFocus(forceFocus);
    }
  }

  function renderScreen() {
    const configuration = props?.configuration;
    const screenData = props;
    const payload = props;
    const parentFocus = props;
    const focused = props;

    const getGroupId = () => {
      if (screenData) {
        return screenData.groupId;
      }
      if (payload) {
        return payload.groupId;
      }
    };

    const screenOptions = {
      segmentKey: null,
      groupId: getGroupId(),
      isPrehook: isPrehook,
      goToScreen: goToScreen,
    };

    function onMaybeLater() {
      const playerHook = isPlayerHook(props?.payload);
      const success = playerHook ? false : true;
      callback &&
        callback({
          success: success,
          error: null,
          payload: payload?.payload,
        });
    }

    function onSignedIn() {
      callback &&
        callback({
          success: true,
          error: null,
          payload: payload?.payload,
        });
    }

    function onMenuButtonClickedSignIn() {
      const playerHook = isPlayerHook(props?.payload);
      if (playerHook) {
        callback &&
          callback({
            success: false,
            error: null,
            payload: payload?.payload,
          });
      } else {
        goToScreen(ScreenData.INTRO);
      }
    }

    switch (screen) {
      case ScreenData.LOADING: {
        return <LoadingScreen {...screenOptions} />;
      }
      case ScreenData.INTRO: {
        return (
          <IntroScreen
            {...screenOptions}
            screenStyles={screenStyles}
            screenLocalizations={screenLocalizations}
            parentFocus={parentFocus}
            focused={focused}
            forceFocus={forceFocus}
            onSignedIn={onSignedIn}
          />
        );
      }
      case ScreenData.LOG_OUT: {
        return (
          <LogoutScreen
            {...screenOptions}
            configuration={configuration}
            screenStyles={screenStyles}
            screenLocalizations={screenLocalizations}
            parentFocus={parentFocus}
            focused={focused}
            forceFocus={forceFocus}
          />
        );
      }
      case ScreenData.LOG_IN: {
        return (
          <SignInScreen
            {...screenOptions}
            configuration={configuration}
            screenStyles={screenStyles}
            screenLocalizations={screenLocalizations}
            onSignedIn={onSignedIn}
            onMenuButtonClicked={onMenuButtonClickedSignIn}
            onMaybeLater={onMaybeLater}
          />
        );
      }
    }
  }
  return renderScreen();
};
