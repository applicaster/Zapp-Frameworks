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
  saveLoginDataToLocalStorage,
  isLoginRequired,
  refreshToken,
} from "./Utils";
import {
  createLogger,
  BaseSubsystem,
  BaseCategories,
} from "../../Services/LoggerService";

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
    configuration: { loginURL, clientId, region },
  } = props;

  const mounted = useRef(true);

  useEffect(() => {
    navigator.hideNavBar();
    navigator.hideBottomBar();
    mounted.current = true;

    setupEnvironment();
    return () => {
      mounted.current = false;
      navigator.showNavBar();
      navigator.showBottomBar();
    };
  }, []);

  async function setupEnvironment() {
    try {
      const userNeedsToLogin = await isLoginRequired();

      if (userNeedsToLogin) {
        logger.debug({
          message: "setupEnvironment: Presenting login screen",
          data: { userNeedsToLogin },
        });
        setLoading(false);
      } else {
        console.log({ clientId, region });
        const success = await refreshToken(clientId, region);
        logger.debug({
          message: `setupEnvironment: Hool finished, refresh Token completed: ${success}`,
          data: { userNeedsToLogin, success },
        });
        mounted.current &&
          callback &&
          callback({ success: true, error: null, payload });
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
      console.log({ data: event.nativeEvent.data });
      logger.debug({
        message: `onMessage: Login screen send event`,
        data: { data },
      });
      await saveLoginDataToLocalStorage(data);
      mounted.current &&
        callback &&
        callback({ success: true, error: null, payload });
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

  function renderFlow() {
    return loading === false ? (
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
    ) : null;
  }

  return renderFlow();
};

export default Login;
