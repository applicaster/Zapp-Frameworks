import React, { useCallback, useEffect, useRef } from "react";
import { View, Text, Platform } from "react-native";
import { useInitialFocus } from "@applicaster/zapp-react-native-utils/focusManager";
import Button from "./Button";
import Layout from "./Layout";
import { mapKeyToStyle } from "../Utils/Customization";
import { ScreenData } from "./Login/utils";

const IntroScreen = (props) => {
  const {
    callback,
    isPrehook,
    groupId,
    goToScreen,
    focused,
    parentFocus,
    forceFocus,
    screenStyles,
    screenLocalizations,
    finishHook,
  } = props;

  const signInButton = useRef(null);
  const laterButton = useRef(null);
  const {
    title_text,
    title_text_hook,
    sing_in_button,
    sing_in_later,
  } = screenLocalizations;
  useEffect(() => {
    if (forceFocus) {
      goToScreen(null, false, true);
    }
  }, []);

  const handleRemoteControlEvent = useCallback(
    (comp, { eventType }) => {
      if (eventType === "menu") {
        finishHook();
      }
    },
    [callback]
  );

  const onSkipPrehook = useCallback(() => {
    finishHook();
  }, [callback]);

  if (Platform.OS === "android") {
    useInitialFocus(isPrehook || forceFocus ? true : focused, signInButton);
  }

  return (
    <Layout
      tvEventHandler={handleRemoteControlEvent}
      screenStyles={screenStyles}
      isPrehook={isPrehook}
    >
      <View style={styles.container}>
        <Text
          style={
            isPrehook
              ? {
                  ...styles.title,
                  ...mapKeyToStyle("title", screenStyles),
                }
              : {
                  ...styles.subTitle,
                  ...mapKeyToStyle("title", screenStyles),
                }
          }
        >
          {isPrehook ? title_text_hook : title_text}
        </Text>
        <View style={styles.buttonContainer}>
          <Button
            screenStyles={screenStyles}
            label={sing_in_button}
            onPress={() => goToScreen(ScreenData.LOG_IN)}
            preferredFocus={true}
            groupId={groupId}
            style={styles.focusContainer}
            buttonRef={signInButton}
            id={"sign-in-button"}
            nextFocusLeft={parentFocus ? parentFocus.nextFocusLeft : null}
            nextFocusDown={isPrehook ? laterButton : null}
          />
          {isPrehook && (
            <Button
              screenStyles={screenStyles}
              label={sing_in_later}
              groupId={groupId}
              onPress={onSkipPrehook}
              style={styles.focusContainer}
              buttonRef={laterButton}
              nextFocusUp={signInButton}
              id={"sign-in-later"}
            />
          )}
        </View>
      </View>
    </Layout>
  );
};

const styles = {
  container: {
    flex: 1,
    alignItems: "center",
    marginTop: 100,
  },
  iconsContainer: {
    width: 1100,
    alignItems: "center",
    justifyContent: "space-between",
    flexDirection: "row",
    marginTop: 50,
    marginBottom: 90,
  },
  title: {
    color: "#525A5C",
    fontSize: 42,
    fontWeight: "bold",
    marginBottom: 300,
  },
  subTitle: {
    color: "#525A5C",
    fontSize: 32,
  },
  altSubTitle: {
    color: "#525A5C",
    fontSize: 32,
    marginBottom: 300,
  },
  buttonContainer: {
    marginTop: 20,
    width: "100%",
    height: 200,
    alignItems: "center",
    justifyContent: "center",
  },
  focusContainer: {
    justifyContent: "center",
    alignItems: "center",
  },
};

IntroScreen.displayName = "IntroScreen";
export default IntroScreen;
