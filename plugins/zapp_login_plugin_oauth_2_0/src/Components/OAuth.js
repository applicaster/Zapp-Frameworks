import React, { useState, useEffect, useLayoutEffect, useRef } from "react";
import { View, SafeAreaView, Platform, Alert } from "react-native";

import * as R from "ramda";

import { useNavigation } from "@applicaster/zapp-react-native-utils/reactHooks/navigation";
import { getLocalizations } from "../Utils/Localizations";
import { isVideoEntry, isAuthenticationRequired } from "../Utils/PayloadUtils";
import LoadingScreen from "./LoadingScreen";
import { container } from "./Styles";
import TitleLabel from "./UIComponents/TitleLabel";
import ClientLogo from "./UIComponents/ClientLogo";
import ActionButton from "./UIComponents/Buttons/ActionButton.js";
import BackButton from "./UIComponents/Buttons/BackButton";

import {
  configFromPlugin,
  authorizeService,
  revokeService,
  checkUserAuthorization,
} from "../Services/OAuth2Service";

import { getStyles } from "../Utils/Customization";
import { isHook } from "../Utils/UserAccount";
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
    R.find(R.propEq("type", "zapp_login_plugin_oauth_2_0")),
    R.values
  );

  return getPropByKey(rivers);
};

const clientLogoView = {
  height: 100,
  width: 350,
  position: "absolute",
  alignSelf: "center",
  top: 200,
};

function showAlertLogout(
  success,
  {
    alert_fail_title,
    alert_logout_fail_message,
    alert_succeed_title,
    alert_logout_succeed_message,
  }
) {
  if (success) {
    Alert.alert(alert_succeed_title, alert_logout_succeed_message);
  } else {
    Alert.alert(alert_fail_title, alert_logout_fail_message);
  }
}

function showAlertLogin(
  success,
  {
    alert_fail_title,
    alert_login_fail_message,
    alert_succeed_title,
    alert_login_succeed_message,
  }
) {
  if (success) {
    Alert.alert(alert_succeed_title, alert_login_succeed_message);
  } else {
    Alert.alert(alert_fail_title, alert_login_fail_message);
  }
}

const OAuth = (props) => {
  const HookTypeData = {
    UNDEFINED: "Undefined",
    PLAYER_HOOK: "PlayerHook",
    SCREEN_HOOK: "ScreenHook",
    USER_ACCOUNT: "UserAccount",
  };

  const navigator = useNavigation();
  const [hookType, setHookType] = useState(HookTypeData.UNDEFINED);
  const [isUserAuthenticated, setIsUserAuthenticated] = useState(false);
  const [loading, setLoading] = useState(true);

  const { callback, payload, rivers } = props;
  const localizations = getRiversProp("localizations", rivers);
  const styles = getRiversProp("styles", rivers);

  const screenStyles = getStyles(styles);
  const screenLocalizations = getLocalizations(localizations);
  const oAuthConfig = configFromPlugin(props?.configuration);
  const {
    logout_text,
    login_text,
    title_text,
    back_button_text,
    alert_fail_title,
    alert_fail_message,
    alert_succeed_title,
    alert_succeed_message,
  } = screenLocalizations;
  const containerStyle = (screenStyles) => {
    return {
      ...container,
      backgroundColor: screenStyles?.background_color,
      flex: 1,
    };
  };

  let stillMounted = true;

  useLayoutEffect(() => {
    const configuration = props?.configuration;
    addContext({ configuration });
    logger
      .createEvent()
      .setLevel(XRayLogLevel.debug)
      .setMessage(`Starting OAuth Plugin`)
      .addData({ configuration })
      .send();

    setupEnvironment();
    return () => {
      stillMounted = false;
    };
  }, []);

  const setupEnvironment = React.useCallback(async () => {
    const videoEntry = isVideoEntry(payload);
    console.log({ oAuthConfig, authenthicationRequired, authenticated });

    const authenticated = await checkUserAuthorization(oAuthConfig);
    const testEnvironmentEnabled =
      props?.configuration?.is_test_environment || false;
    const authenthicationRequired =
      testEnvironmentEnabled === true || isAuthenticationRequired({ payload });
    let event = logger.createEvent().setLevel(XRayLogLevel.debug).addData({
      is_video_entry: videoEntry,
    });

    if (videoEntry) {
      if (authenthicationRequired === false || authenticated) {
        event
          .setMessage(`Plugin finished work`)
          .addData({
            hook_type: HookTypeData.PLAYER_HOOK,
            is_video_entry: true,
            authenticated: authenticated,
            is_authentication_required: authenthicationRequired,
          })
          .send();
        callback && callback({ success: true, error: null, payload: payload });
      } else if (oAuthConfig) {
        event
          .setMessage(`Plugin hook_type: ${HookTypeData.PLAYER_HOOK}`)
          .addData({
            hook_type: HookTypeData.PLAYER_HOOK,
          })
          .send();
        stillMounted && setHookType(HookTypeData.PLAYER_HOOK);
      } else {
        const error = Error(
          "OAuth plugin required configuration keys not defined, please check plugin configuration in Zapp"
        );

        logger
          .createEvent()
          .setLevel(XRayLogLevel.error)
          .setMessage("OAuth finishing, config parameters was not difined")
          .addData({
            error,
          })
          .send();

        callback && callback({ success: false, error, payload });
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
    stillMounted && setIsUserAuthenticated(authenticated);
    stillMounted && setLoading(false);
  }, [isUserAuthenticated]);

  const onPressActionButton = React.useCallback(async () => {
    setLoading(true);
    if (isUserAuthenticated) {
      const success = await revokeService(oAuthConfig);
      const authenticated = await checkUserAuthorization(oAuthConfig);

      logger
        .createEvent()
        .setLevel(XRayLogLevel.debug)
        .setMessage(`onPressActionButton: Logout Success`)
        .addData({
          success,
          authenticated,
          hookType,
        })
        .send();
      showAlertLogout(success, screenLocalizations);
      setIsUserAuthenticated(authenticated);
    } else {
      const success = await authorizeService(oAuthConfig);
      const authenticated = await checkUserAuthorization(oAuthConfig);
      logger
        .createEvent()
        .setLevel(XRayLogLevel.debug)
        .setMessage(`onPressActionButton: Login Success`)
        .addData({
          success,
          authenticated,
          hookType,
        })
        .send();
      setIsUserAuthenticated(authenticated);
      if (authenticated) {
        if (hookType === HookTypeData.PLAYER_HOOK) {
          logger
            .createEvent()
            .setLevel(XRayLogLevel.debug)
            .setMessage(`onPressActionButton: OAuth finished`)
            .addData({
              success,
              authenticated,
              hookType,
            })
            .send();
          callback &&
            callback({ success: true, error: null, payload: payload });
        } else {
          showAlertLogin(success, screenLocalizations);
        }
      } else {
        showAlertLogin(success, screenLocalizations);
      }
    }
    setLoading(false);
  }, [isUserAuthenticated, hookType]);

  const onBackButton = () => {
    callback && callback({ success: false, error: null, payload });
  };

  const SafeArea = Platform.isTV ? View : SafeAreaView;

  const safeZoneBackgroundColor =
    hookType === HookTypeData.UNDEFINED
      ? "black"
      : screenStyles?.background_color;
  return (
    <SafeArea style={{ flex: 1, backgroundColor: safeZoneBackgroundColor }}>
      {hookType === HookTypeData.UNDEFINED ? null : (
        <View style={containerStyle(screenStyles)}>
          <BackButton
            title={back_button_text}
            disabled={hookType !== HookTypeData.PLAYER_HOOK}
            screenStyles={screenStyles}
            onPress={onBackButton}
          />
          <TitleLabel screenStyles={screenStyles} title={title_text} />
          <View style={clientLogoView}>
            <ClientLogo imageSrc={screenStyles.client_logo} />
          </View>
          <ActionButton
            screenStyles={screenStyles}
            title={isUserAuthenticated ? logout_text : login_text}
            onPress={onPressActionButton}
          />
        </View>
      )}
      {loading && <LoadingScreen />}
    </SafeArea>
  );
};

export default OAuth;
