// @flow
import React, { useState, useEffect } from "react";
import {
  Text,
  View,
  Dimensions,
  ActivityIndicator,
  Platform,
  Image,
} from "react-native";

import { connectToStore } from "@applicaster/zapp-react-native-redux";
import { getFromLocalStorage, isItemInStorage } from "../Utils";
import Button from "../Components/Button";
import createStyleSheet from "../Styles/Styles";
import trackEvent from "../Analytics";
import ASSETS from "../Styles/Assets";
import EVENTS from "../Analytics/config";

const { height, width } = Dimensions.get("window");
const aspectRatio = height / width;
const isMobile = !Platform.isTV;
const isPad = isMobile && aspectRatio < 1.6;

const storeConnector = connectToStore((state) => {
  const loginPlugin = state.plugins.find(({ type }) => type === "login");
  const screenId = "42043a23-6ff1-4a30-b509-cffa075abb66";
  const values = Object.values(state.rivers);
  // eslint-disable-next-line array-callback-return,consistent-return
  console.log({ identifier: loginPlugin.identifier });
  const plugin = values.find((item) => {
    if (item && item.type) {
      console.log({ item });
      if (screenId) {
        return item.id === screenId;
      }
      return item.type === loginPlugin.identifier;
    }
  });
  console.log({ plugin });
  return { plugin };
});

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
  screenData: {
    general: any,
  },
  plugin: {},
  focused: boolean,
  parentFocus: {},
};

function AccountComponent(props: Props) {
  const { plugin, screenData = {}, navigator, focused, parentFocus } = props;

  const {
    general: {
      account_component_greetings_text: greetings,
      account_component_instructions_text: instructions,
      login_action_button_text: loginLabel,
      logout_action_button_text: logoutLabel,
      login_action_button_background_color: loginButtonBackground,
      logout_action_button_background_color: logoutButtonBackground,
    } = {},
  } = screenData || {};

  const {
    greetingsStyle,
    instructionsStyle,
    logoutButtonStyle,
    loginButtonStyle,
    authProviderTitleStyle,
    ,
  } = createStyleSheet(screenData);

  const [authProviderItem, setAuthProviderItem] = useState(null);
  const [isLoggedIn, setIsLoggedIn] = useState(null);
  const [loading, setIsLoading] = useState(false);

  useEffect(() => {
    setIsLoading(true);
    start().catch((err) => console.log(err));
  }, [navigator.previousAction]);

  const checkAuthProvider = async () => {
    const isAuthProviderExist = await isItemInStorage("authProviderID");
    if (isAuthProviderExist) {
      const provider = await getFromLocalStorage("authProviderID");
      setAuthProviderItem(provider);
    }
  };

  // eslint-disable-next-line consistent-return
  const start = async () => {
    try {
      await checkAuthProvider();
      const token = await isItemInStorage("idToken");
      return token ? setIsLoggedIn(true) : setIsLoggedIn(false);
    } catch (err) {
      setIsLoggedIn(false);
    } finally {
      setIsLoading(false);
    }
  };

  // eslint-disable-next-line consistent-return
  async function handlePress() {
    try {
      setIsLoading(true);
      trackEvent(EVENTS.clickLogin, { screenData });
      navigator.push(plugin);
    } catch (err) {
      console.log(err);
      return isLoggedIn
        ? trackEvent(EVENTS.logoutFailure, { screenData })
        : trackEvent(EVENTS.loginFailure, { screenData });
    } finally {
      setIsLoading(false);
    }
  }

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

export default storeConnector(AccountComponent);
