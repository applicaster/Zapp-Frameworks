// @flow
import React, { useState, useEffect, useRef } from "react";
import {
  Text,
  View,
  Dimensions,
  ActivityIndicator,
  Platform,
  Image,
  AppState,
} from "react-native";

import SSOBridge from "../../../SSOBridge";
import {
  presentLoginFailAlert,
  presentLogoutAlert,
} from "../Components/AlertActions";

import { isItemInStorage } from "../../../Utils";
import Button from "../Components/Button";
import createStyleSheet from "../Styles/Styles";
import trackEvent from "../Analytics";
import ASSETS from "../Styles/Assets";
import EVENTS from "../Analytics/config";

const { height, width } = Dimensions.get("window");
const aspectRatio = height / width;
const isMobile = !Platform.isTV;
const isPad = isMobile && aspectRatio < 1.6;

type Props = {
  dimensions: {
    window: { height: number },
  },
  navigator: {
    push: ({}) => void,
    previousAction: string,
  },
  state: {
    plugins: [
      {
        type: string,
        identifier: string,
      }
    ],
    rivers: {},
  },
  configuration: { fallback_login_plugin_id: string },
  screenData: {
    general: any,
  },
  plugin: {},
  focused: boolean,
  parentFocus: {},
  screenGeneralStyles: {},
};

function AccountComponent(props: Props) {
  const {
    plugin,
    screenData = {},
    navigator,
    focused,
    parentFocus,
    configuration,
    screenGeneralStyles,
  } = props;

  const {
    general: {
      account_component_greetings_text: greetings,
      account_component_instructions_text: instructions,
      login_action_button_text: loginLabel,
      login_action_button_applicaster_text: loginLabelApplicaster,
      logout_action_button_text: logoutLabel,
      login_action_button_applicaster_background_color: loginButtonApplicasterBackground,
      login_action_button_background_color: loginButtonBackground,
      logout_action_button_background_color: logoutButtonBackground,
    } = {},
  } = screenData || {};

  const { fallback_login_plugin_id } = configuration;

  const {
    greetingsStyle,
    instructionsStyle,
    logoutButtonStyle,
    loginButtonStyle,
    authProviderTitleStyle,
    loginButtonApplicasterStyle,
  } = createStyleSheet(screenData);

  const SSOProviderType = {
    UNDEFINED: "Undefined",
    APPLE_SSO: "AppleSSO",
    LOGIN_PLUGIN_SSO: "LoginPluginSSO",
  };

  const appState = useRef(AppState.currentState);
  const [authProviderItem, setAuthProviderItem] = useState(null);

  const [providerType, setProviderType] = useState(SSOProviderType.UNDEFINED);
  const [isLoggedIn, setIsLoggedIn] = useState(null);
  const [loading, setIsLoading] = useState(false);
  const [appStateVisible, setAppStateVisible] = useState(appState.current);

  useEffect(() => {
    const appStateChange = "change";
    setIsLoading(true);
    AppState.addEventListener(appStateChange, _handleAppStateChange);
    start().catch((err) => console.log(err));

    return () => {
      AppState.removeEventListener(appStateChange, _handleAppStateChange);
    };
  }, []);

  useEffect(() => {
    setIsLoading(true);
    start().catch((err) => console.log(err));
  }, [navigator.previousAction]);

  useEffect(() => {
    setIsLoading(false);
  }, [isLoggedIn]);

  useEffect(() => {
    if (appStateVisible) {
      console.log("appStateVisible");
      setIsLoading(true);
      start().catch((err) => console.log(err));
    }
  }, [appStateVisible]);

  const _handleAppStateChange = (nextAppState) => {
    if (
      appState.current.match(/inactive|background/) &&
      nextAppState === "active"
    ) {
      console.log("App has come to the foreground!");
    }

    appState.current = nextAppState;
    setAppStateVisible(appState.current);
    console.log("AppState", appState.current);
  };

  // eslint-disable-next-line consistent-return
  const start = async () => {
    try {
      await checkUserSignedIn();
    } catch (err) {
      setIsLoggedIn(false);
    } finally {
      setIsLoading(false);
    }
  };

  async function checkUserSignedIn() {
    let isSignedIn = await SSOBridge.isSignedIn();

    if (isSignedIn) {
      setProviderType(SSOProviderType.APPLE_SSO);
    } else {
      isSignedIn = await isItemInStorage("idToken", fallback_login_plugin_id);

      if (isSignedIn) {
        setProviderType(SSOProviderType.LOGIN_PLUGIN_SSO);
      }
    }

    return isSignedIn ? setIsLoggedIn(true) : setIsLoggedIn(false);
  }

  async function performButtonAction() {
    if (isLoggedIn) {
      return await signOutLogic();
    } else {
      const result = await SSOBridge.signIn();

      if (result) {
        setProviderType(SSOProviderType.APPLE_SSO);
      } else {
        presentLoginFailAlert(screenGeneralStyles, plugin, navigator);
      }

      return result;
    }
  }

  async function signOutLogic() {
    console.log({ providerType });

    if (providerType === SSOProviderType.APPLE_SSO) {
      await SSOBridge.signOut();
      presentLogoutAlert(screenGeneralStyles, plugin, navigator);
    } else if (providerType === SSOProviderType.LOGIN_PLUGIN_SSO) {
      navigator.push(plugin);
    }

    return true;
  }

  // eslint-disable-next-line consistent-return
  async function handleLoginApplicaster() {
    navigator.push(plugin);
  }

  // eslint-disable-next-line consistent-return
  async function handlePress() {
    try {
      setIsLoading(true);
      trackEvent(EVENTS.clickLogin, { screenData });
      const result = await performButtonAction();
      setIsLoggedIn(result);
    } catch (err) {
      console.log(err);

      return isLoggedIn
        ? trackEvent(EVENTS.logoutFailure, { screenData })
        : trackEvent(EVENTS.loginFailure, { screenData });
    } finally {
      setIsLoading(false);
    }
  }

  // NOT IN WORK, need to fix to support
  const renderAuthorizationProvider = () => {
    if (!authProviderItem) {
      return null;
    }

    const {
      mobile_screen_logo: authProviderMobileLogo,
      tablet_screen_logo: authProviderTabletLogo,
      tv_screen_logo: authProviderTVLogo,
      title: authProviderTitle,
    } = authProviderItem;

    if (!isMobile && authProviderTVLogo) {
      return renderProviderImage(authProviderTVLogo);
    }

    if (isPad && authProviderTabletLogo) {
      return renderProviderImage(authProviderTabletLogo);
    }

    if (!isPad && authProviderMobileLogo) {
      return renderProviderImage(authProviderMobileLogo);
    }

    return authProviderTitle ? renderProviderTitle(authProviderTitle) : null;
  };

  const renderProviderImage = (imageUrl) => {
    return <Image style={styles.providerImage} source={{ uri: imageUrl }} />;
  };

  const renderProviderTitle = (title) => {
    return (
      <Text
        // eslint-disable-next-line react-native/no-inline-styles
        style={[{ textAlign: "center", marginTop: 5 }, authProviderTitleStyle]}
        ellipsizeMode="tail"
      >
        {title}
      </Text>
    );
  };

  return (
    <View style={styles.layout}>
      {loading ? (
        <ActivityIndicator color="white" size="large" />
      ) : (
        <>
          <Text
            style={[
              { textAlign: "center" },
              isLoggedIn ? greetingsStyle : instructionsStyle,
            ]}
            numberOfLines={4}
            ellipsizeMode="tail"
          >
            {isLoggedIn ? greetings : instructions}
          </Text>
          {isLoggedIn && renderAuthorizationProvider()}
          <Button
            label={isLoggedIn ? logoutLabel : loginLabel}
            onPress={handlePress}
            textStyle={isLoggedIn ? logoutButtonStyle : loginButtonStyle}
            buttonStyle={styles.input}
            backgroundColor={
              isLoggedIn ? logoutButtonBackground : loginButtonBackground
            }
            backgroundButtonUri={ASSETS.loginButtonBackground}
            backgroundButtonUriActive={ASSETS.loginButtonBackgroundActive}
            focus={focused}
            parentFocus={parentFocus}
          />
          {!isLoggedIn ? (
            <Button
              label={loginLabelApplicaster}
              onPress={handleLoginApplicaster}
              textStyle={loginButtonApplicasterStyle}
              buttonStyle={styles.input}
              backgroundColor={loginButtonApplicasterBackground}
              backgroundButtonUri={ASSETS.loginButtonBackground}
              backgroundButtonUriActive={ASSETS.loginButtonBackgroundActive}
              focus={focused}
              parentFocus={parentFocus}
            />
          ) : null}
        </>
      )}
    </View>
  );
}

const mobileInput = {
  width: isPad ? 500 : 300,
  height: isPad ? 90 : 50,
  marginTop: isPad ? 100 : 60,
};

const tvInput = {
  width: 600,
  height: 90,
  marginTop: 130,
};

const tvLayout = {
  marginTop: 50,
};

const mobileLayout = {
  justifyContent: "center",
  paddingBottom: "20%",
  paddingHorizontal: "5%",
};

const styles = {
  providerImage: {
    marginTop: 5,
    height: 100,
    width: "100%",
    resizeMode: "contain",
  },
  layout: {
    flex: 1,
    alignItems: "center",
    width: "100%",
    height,
    ...(isMobile ? mobileLayout : tvLayout),
  },
  input: {
    justifyContent: "center",
    alignItems: "center",
    ...(isMobile ? mobileInput : tvInput),
  },
};

export default AccountComponent;
