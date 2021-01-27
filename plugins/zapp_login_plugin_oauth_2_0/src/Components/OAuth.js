import React, { useState, useLayoutEffect } from "react";
import {
  View,
  SafeAreaView,
  Platform,
  ImageBackground,
  useWindowDimensions,
} from "react-native";

import { useNavigation } from "@applicaster/zapp-react-native-utils/reactHooks/navigation";
import { getLocalizations } from "../Utils/Localizations";
import { isVideoEntry, isAuthenticationRequired } from "../Utils/PayloadUtils";
import LoadingScreen from "./LoadingScreen";
import {
  clientLogoView,
  containerStyle,
  safeAreaStyle,
  backgroundImageStyle,
} from "./Styles";
import TitleLabel from "./UIComponents/TitleLabel";
import ClientLogo from "./UIComponents/ClientLogo";
import ActionButton from "./UIComponents/Buttons/ActionButton.js";
import BackButton from "./UIComponents/Buttons/BackButton";
import {
  showAlertLogout,
  showAlertLogin,
  getRiversProp,
  HookTypeData,
} from "../Utils/Helpers";
import {
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
import { getConfig } from "../Services/Providers";

export const logger = createLogger({
  subsystem: BaseSubsystem,
  category: BaseCategories.GENERAL,
});

const OAuth = (props) => {
  const windowWidth = useWindowDimensions().width;
  const windowHeight = useWindowDimensions().height;
  const navigator = useNavigation();
  const [hookType, setHookType] = useState(HookTypeData.UNDEFINED);
  const [isUserAuthenticated, setIsUserAuthenticated] = useState(false);
  const [loading, setLoading] = useState(true);

  const { callback, payload, rivers } = props;
  const localizations = getRiversProp("localizations", rivers);
  const styles = getRiversProp("styles", rivers);

  const screenStyles = getStyles(styles);
  const screenLocalizations = getLocalizations(localizations);
  const oAuthConfig = getConfig({ configuration: props?.configuration });
  const session_storage_key = props?.session_storage_key;

  const {
    logout_text,
    login_text,
    title_text,
    back_button_text,
  } = screenLocalizations;

  let stillMounted = true;

  useLayoutEffect(() => {
    const configuration = props?.configuration;
    addContext({ configuration, oauth_config: oAuthConfig });
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
    const authenticated = await checkUserAuthorization(
      oAuthConfig,
      session_storage_key
    );
    const testEnvironmentEnabled =
      props?.configuration?.force_authentication_on_all || "off";
    const authenticationRequired =
      testEnvironmentEnabled === "on" || isAuthenticationRequired({ payload });
    let event = logger.createEvent().setLevel(XRayLogLevel.debug).addData({
      is_video_entry: videoEntry,
    });
    if (videoEntry) {
      if (authenticationRequired === false || authenticated) {
        event
          .setMessage(`Plugin finished work`)
          .addData({
            hook_type: HookTypeData.PLAYER_HOOK,
            is_video_entry: true,
            authenticated: authenticated,
            is_authentication_required: authenticationRequired,
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
      const success = await revokeService(oAuthConfig, session_storage_key);
      const authenticated = await checkUserAuthorization(
        oAuthConfig,
        session_storage_key
      );

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
      const success = await authorizeService(oAuthConfig, session_storage_key);
      const authenticated = await checkUserAuthorization(
        oAuthConfig,
        session_storage_key
      );
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
  return (
    <>
      {hookType === HookTypeData.UNDEFINED ? null : (
        <ImageBackground
          style={backgroundImageStyle(
            screenStyles,
            hookType,
            windowWidth,
            windowHeight
          )}
          source={{ uri: screenStyles.background_image }}
        />
      )}
      <SafeArea style={safeAreaStyle}>
        {hookType === HookTypeData.UNDEFINED ? null : (
          <View style={containerStyle}>
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
    </>
  );
};

export default OAuth;
