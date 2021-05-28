import React, { useEffect, useRef } from "react";
import { View, Text, Platform } from "react-native";
import { useInitialFocus } from "@applicaster/zapp-react-native-utils/focusManager";
import Button from "./Button";
import Layout from "./Layout";
import { pleaseLogOut } from "../Services/OAuth2Service";
import { mapKeyToStyle } from "../Utils/Customization";
import { showAlert, ScreenData } from "./Login/utils";
import {
  removeDataFromStorages,
  storageGet,
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
    isPrehook,
  } = props;

  const { sing_out, sing_out_url_text, sing_out_url } = screenLocalizations;

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
    prepareComponent();
  }, []);

  const prepareComponent = async () => {
    if (forceFocus) {
      goToScreen(null, false, true);
    }
  };

  const handleSignOut = async () => {
    try {
      const accessToken = await storageGet(AuthDataKeys.access_token);
      await pleaseLogOut(configuration, accessToken);
      await removeDataFromStorages();
      goToScreen(ScreenData.INTRO);
      logger.debug({
        message: "handleSignOut: Sign out complete",
      });
    } catch (error) {
      logger.debug({
        message: "handleSignOut: error",
        data: { error },
      });
      showAlert(
        screenLocalizations?.general_error_title,
        screenLocalizations?.general_error_message
      );
    }
  };

  if (Platform.OS === "android") {
    useInitialFocus(forceFocus || focused, signoutButton);
  }

  return (
    <Layout screenStyles={screenStyles} isPrehook={isPrehook}>
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
