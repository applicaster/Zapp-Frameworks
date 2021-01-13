import React, { useState, useLayoutEffect } from "react";
import { View, SafeAreaView, Platform, Text } from "react-native";

// import AccountFlow from "./AccountFlow";
// import LogoutFlow from "./LogoutFlow";
import * as R from "ramda";

import { useNavigation } from "@applicaster/zapp-react-native-utils/reactHooks/navigation";
import { localStorage as defaultStorage } from "@applicaster/zapp-react-native-bridge/ZappStorage/LocalStorage";
import { getLocalizations } from "../Utils/Localizations";
import { isVideoEntry, isAuthenticationRequired } from "../Utils/PayloadUtils";
import { showAlert } from "../Utils/Account";
import LoadingScreen from "./LoadingScreen";
import { container } from "./Styles";
import TitleLabel from "./UIComponents/TitleLabel";
import ClientLogo from "./UIComponents/ClientLogo";
import ActionButton from "./UIComponents/Buttons/ActionButton.js";

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

const OAuth = (props) => {
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
  const [loading, setLoading] = useState(true);

  const { callback, payload, rivers } = props;
  const localizations = getRiversProp("localizations", rivers);
  const styles = getRiversProp("styles", rivers);

  const screenStyles = getStyles(styles);
  const screenLocalizations = getLocalizations(localizations);

  const containerStyle = (screenStyles) => {
    return {
      ...container,
      backgroundColor: screenStyles?.background_color,
    };
  };

  let stillMounted = true;

  useLayoutEffect(() => {
    setupEnvironment();
  }, []);

  const checkIdToken = async () => {
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
      configuration: {
        clientId,
        redirectUrl,
        authorizationEndpoint,
        tokenEndpoint,
        revocationEndpoint,
      },
    } = props;
    addContext({ configuration: props.configuration, payload });

    logger
      .createEvent()
      .setLevel(XRayLogLevel.debug)
      .setMessage(`Starting InPlayer Plugin`)
      .addData()
      .send();

    await checkIdToken();

    const videoEntry = isVideoEntry(payload);
    let event = logger.createEvent().setLevel(XRayLogLevel.debug);

    if (videoEntry) {
      const authenticationRequired = true;
      // isAuthenticationRequired({ payload });

      event.addData({
        authentication_required: authenticationRequired,
        is_video_entry: videoEntry,
      });
      if (authenticationRequired) {
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

  const renderScreenHook = () => {
    return <View style={{ flex: 1, backgroundColor: "red" }} />;
    // return (
    //   <AccountFlow
    //     setParentLockWasPresented={setParentLockWasPresented}
    //     parentLockWasPresented={parentLockWasPresented}
    //     shouldShowParentLock={shouldShowParentLock}
    //     accountFlowCallback={accountFlowCallback}
    //     backButton={!isHomeScreen(navigator)}
    //     screenStyles={screenStyles}
    //     screenLocalizations={screenLocalizations}
    //     {...props}
    //   />
    // );
  };

  // const renderLogoutScreen = () => {
  //   return (
  //     <LogoutFlow
  //       screenStyles={screenStyles}
  //       screenLocalizations={screenLocalizations}
  //       {...props}
  //     />
  //   );
  // };

  const onPressActionButton = () => {};

  const renderUACFlow = () => {
    return idToken ? renderLogoutScreen() : renderScreenHook();
  };

  const shouldShowParentLock = (parentLockWasPresented) =>
    !(parentLockWasPresented || !showParentLock);

  const renderFlow = () => {
    switch (hookType) {
      case HookTypeData.PLAYER_HOOK:
        return renderScreenHook();
      case HookTypeData.SCREEN_HOOK:
        return renderScreenHook();
      case HookTypeData.USER_ACCOUNT:
        return renderScreenHook();
      case HookTypeData.UNDEFINED:
        return null;
    }
  };
  const SafeArea = Platform.isTV ? View : SafeAreaView;
  const { logout_text, login_text, title_text } = screenLocalizations;
  console.log({ screenStyles, styles });
  return (
    // <View style={containerStyle(screenStyles)}>
    <SafeArea style={containerStyle(screenStyles)}>
      {/* {loading && <LoadingScreen />} */}
      <TitleLabel screenStyles={screenStyles} title={title_text} />
      <View style={clientLogoView}>
        <ClientLogo imageSrc={screenStyles.client_logo} />
      </View>
      <ActionButton
        screenStyles={screenStyles}
        title={isUserAuthenticated ? logout_text : login_text}
        onPress={onPressActionButton}
      />
    </SafeArea>
    // </View>
  );
};

export default OAuth;
