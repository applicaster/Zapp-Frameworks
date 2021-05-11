import React, { useState, useEffect, useCallback, useRef } from "react";
import { Platform, View } from "react-native";
// https://github.com/testshallpass/react-native-dropdownalert#usage
import DropdownAlert from "react-native-dropdownalert";
import { isWebBasedPlatform } from "../../Utils/Platform";
import { showAlert } from "../../Utils/Account";
import AccountComponents from "@applicaster/applicaster-account-components";
import * as R from "ramda";
import { useNavigation } from "@applicaster/zapp-react-native-utils/reactHooks/navigation";
import { getLocalizations } from "../../Utils/Localizations";
import { isAuthenticationRequired } from "../../Utils/PayloadUtils";
import { getStyles, isHomeScreen } from "../../Utils/Customization";
import { isHook } from "../../Utils/UserAccount";
import { getRiversProp } from "./Utils";
import { WebView } from "react-native-webview";

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
  const [parentLockWasPresented, setParentLockWasPresented] = useState(false);
  const [idToken, setIdtoken] = useState(null);
  const [hookType, setHookType] = useState(HookTypeData.UNDEFINED);
  const [loading, setLoading] = useState(true);
  const [lastEmailUsed, setLastEmailUsed] = useState(null);
  const [dropDownAlertRef, setDropDownAlertRef] = useState(null);
  const { callback, payload, rivers } = props;
  const screenId = navigator?.activeRiver?.id;

  const localizations = getRiversProp("localizations", rivers, screenId);
  const styles = getRiversProp("styles", rivers, screenId);
  const general = getRiversProp("general", rivers, screenId);

  const screenStyles = getStyles(styles);
  const screenLocalizations = getLocalizations(localizations);

  const {
    configuration: { publisherId, logout_completion_action = "go_back" },
  } = props;
  const showParentLock =
    screenStyles?.import_parent_lock === "1" ? true : false;
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

  async function setupEnvironment() {}

  function renderAccount() {
    return (
      <View
        style={{ flex: 1, backgroundColor: screenStyles?.background_color }}
      ></View>
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

  // {renderScreen()}
  //       {loading && <AccountComponents.LoadingScreen />}
  function renderFlow() {
    return (
      <View
        style={{
          flex: 1,
          backgroundColor: screenStyles?.background_color,
        }}
      >
        <WebView
          source={{
            uri: "https://github.com/react-native-webview/react-native-webview",
          }}
          onMessage={(event) => {
            console.log({ data: event.nativeEvent.data });
          }}
        />

        {!Platform.isTV && !isWebBasedPlatform && (
          <DropdownAlert ref={(ref) => setDropDownAlertRef(ref)} />
        )}
      </View>
    );
  }

  return renderFlow();
};

export default Login;
