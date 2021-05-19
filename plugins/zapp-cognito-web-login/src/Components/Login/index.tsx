import React, { useState, useEffect, useCallback, useRef } from "react";
import { Platform, View } from "react-native";
import { showAlert } from "../../Utils/Account";
import { useNavigation } from "@applicaster/zapp-react-native-utils/reactHooks/navigation";
import { getLocalizations } from "../../Utils/Localizations";
import { getStyles } from "../../Utils/Customization";
import { getRiversProp } from "./Utils";
import { WebView } from "react-native-webview";
import { SafeAreaView } from "@applicaster/zapp-react-native-ui-components/Components/SafeAreaView";
import {
  saveLoginDataToStorages,
  isLoginRequired,
  refreshToken,
  removeDataFromStorages,
  isAuthenticationRequired,
  isPlayerHook,
  isHomeScreen,
} from "./Utils";
import {
  createLogger,
  BaseSubsystem,
  BaseCategories,
} from "../../Services/LoggerService";
import FloatingButton from "../FloatingButton";

const logger = createLogger({
  subsystem: BaseSubsystem,
  category: BaseCategories.GENERAL,
});

const Login = (props) => {
  const HookTypeData = {
    UNDEFINED: "Undefined",
    PLAYER_HOOK: "PlayerHook",
    SCREEN_HOOK: "ScreenHook",
    USER_ACCOUNT: "UserAccount",
  };

  const navigator = useNavigation();
  const [loading, setLoading] = useState(true);
  const { callback, payload, rivers } = props;
  const screenId = navigator?.activeRiver?.id;

  const localizations = getRiversProp("localizations", rivers, screenId);
  const styles = getRiversProp("styles", rivers, screenId);
  const general = getRiversProp("general", rivers, screenId);

  const screenStyles = getStyles(styles);
  const screenLocalizations = getLocalizations(localizations);
  const {
    configuration: { loginURL, clientId, region, logout_completion_action },
  } = props;

  const mounted = useRef(true);

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
        setLoading(false);
      } else {
        const success = await refreshToken(clientId, region);
        logger.debug({
          message: `setupEnvironment: Hook finished, refresh Token completed: ${success}`,
          data: { userNeedsToLogin, success },
        });

        if (callback) {
          mounted.current &&
            callback &&
            callback({ success: true, error: null, payload });
        } else {
          setLoading(false);
        }
      }
    } catch (error) {
      setLoading(false);
      logger.error({
        message: "setupEnvironment: Error",
        data: { error },
      });
      showAlert(
        screenLocalizations?.general_error_title,
        screenLocalizations?.general_error_message
      );
    }
  }

  async function onMessage(event) {
    try {
      const data = event?.nativeEvent?.data;
      const parsedData = JSON.parse(data);

      logger.debug({
        message: `onMessage: Login screen send event`,
        data: { data, parsed_data: parsedData },
      });
      if (parsedData?.action === "logout") {
        if (parsedData?.success === false) {
          throw Error("onMessage: Logout failed from the web service");
        }
        await removeDataFromStorages();
        if (logout_completion_action === "go_home") {
          navigator.goHome();
        }
      } else {
        await saveLoginDataToStorages(parsedData);
        const success = await refreshToken(clientId, region);

        logger.debug({
          message: `onMessage: Login screen completed: ${success}`,
          data: { data },
        });
        mounted.current &&
          callback &&
          callback({ success: true, error: null, payload });
      }
    } catch (error) {
      logger.error({
        message: `onMessage: error`,
        data: { error },
      });
      showAlert(
        screenLocalizations?.general_error_title,
        screenLocalizations?.general_error_message
      );
    }
  }

  function onClose() {
    mounted.current &&
      callback &&
      callback({ success: false, error: null, payload });
    logger.debug({
      message: `onClose: Close button pushed`,
    });
  }

  function renderFlow() {
    return loading === false ? (
      <>
        <SafeAreaView
          style={{
            flex: 1,
            backgroundColor: screenStyles?.background_color,
          }}
        >
          {loading === false && (
            <WebView
              source={{
                uri: loginURL,
              }}
              onMessage={onMessage}
            />
          )}
        </SafeAreaView>
        {loading === false && payload && isHomeScreen(navigator) === false && (
          <FloatingButton
            screenStyles={screenStyles}
            screenLocalizations={screenLocalizations}
            onClose={onClose}
          />
        )}
      </>
    ) : null;
  }

  return renderFlow();
};

export default Login;
