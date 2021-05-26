import React, { useEffect, useRef, useState } from "react";
import axios from "axios";
import { View, Text, Platform } from "react-native";
import { useInitialFocus } from "@applicaster/zapp-react-native-utils/focusManager";
import { localStorage } from "@applicaster/zapp-react-native-bridge/ZappStorage/LocalStorage";
import Button from "../Components/Button";
import Layout from "../Components/Layout";
import { pleaseLogOut } from "../Services/OAuth2Service";
import { mapKeyToStyle } from "../Utils/Customization";

import {
  removeDataFromStorages,
  getItem,
  AuthDataKeys,
} from "../Services/StorageService";
import {
  createLogger,
  BaseSubsystem,
  BaseCategories,
} from "../Services/LoggerService";

const logger = createLogger({
  subsystem: BaseSubsystem,
  category: BaseCategories.GENERAL,
});

const LogoutScreen = (props) => {
  const {
    groupId,
    parentFocus,
    focused,
    goToScreen,
    forceFocus,
    screenStyles,
    screenLocalizations,
    configuration,
  } = props;

  const { sing_out, sing_out_url_text, sing_out_url } = screenLocalizations;
  const [accessToken, setAccessToken] = useState("");

  const signoutButton = useRef(null);

  const styles = {
    container: {
      flex: 1,
      alignItems: "flex-start",
      marginTop: 100,
    },
    text: {
      ...mapKeyToStyle("text", screenStyles),
      fontSize: 32,
      marginBottom: 20,
    },

    url: {
      ...mapKeyToStyle("text_url", screenStyles),

      fontWeight: "bold",
      fontSize: 36,
      marginBottom: 60,
    },
    buttonContainer: {
      marginTop: 80,
      flexDirection: "row",
      alignItems: "center",
      justifyContent: "center",
      alignSelf: "center",
    },
  };

  useEffect(() => {
    getAccessData();
  }, []);

  const getAccessData = async () => {
    const accessToken = await getItem(
      AuthDataKeys.access_toke,
      namespace
    ).catch((err) => console.log(err, name));
    setAccessToken(accessToken);
    if (forceFocus) {
      goToScreen(null, false, true);
    }
  };

  const handleSignOut = async () => {
    await pleaseLogOut(configuration, accessToken);
  };

  if (Platform.OS === "android") {
    useInitialFocus(forceFocus || focused, signoutButton);
  }

  return (
    <Layout screenStyles={screenStyles}>
      <View style={styles.container}>
        <Text style={styles.text}>
          {`${sing_out_url_text} `}
          <Text style={styles.url}>{sing_out_url}</Text>
        </Text>
        <Button
          screenStyles={screenStyles}
          label={sing_out}
          onPress={() => handleSignOut()}
          preferredFocus={true}
          groupId={groupId}
          style={styles.buttonContainer}
          buttonRef={signoutButton}
          id={"sign-out-button"}
          nextFocusLeft={parentFocus ? parentFocus.nextFocusLeft : null}
        />
      </View>
    </Layout>
  );
};

LogoutScreen.displayName = "LogoutScreen";
export default LogoutScreen;
