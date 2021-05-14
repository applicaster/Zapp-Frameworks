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
    configuration: { loginURL },
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
      console.log({ userNeedsToLogin });
      if (userNeedsToLogin) {
        setLoading(false);
      } else {
        const success = await refreshToken();
        if (success) {
          // mounted.current &&
          //   callback &&
          //   callback({ success: true, error: null, payload });
        }
      }
    } catch (error) {
      setLoading(false);
      console.log({ error });
    }
  }

  async function onMessage(event) {
    const data = event?.nativeEvent?.data;
    console.log({ data: event.nativeEvent.data });
    const result = await saveLoginDataToLocalStorage(data);

    //TODO: Uncommit
    // mounted.current &&
    //   callback &&
    //   callback({ success: true, error: null, payload });
  }
  // {renderScreen()}
  //       {loading && <AccountComponents.LoadingScreen />}
  function renderFlow() {
    return (
      <SafeAreaView
        style={{
          flex: 1,
          backgroundColor: screenStyles?.background_color,
        }}
      >
        {loading == true && (
          <WebView
            source={{
              uri: loginURL,
            }}
            onMessage={onMessage}
          />
        )}
      </SafeAreaView>
    );
  }

  return renderFlow();
};

export default Login;
