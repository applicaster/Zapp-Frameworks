import React, { useCallback, useEffect, useRef } from 'react'
import { View, Text, Platform } from "react-native";
import { useInitialFocus } from "@applicaster/zapp-react-native-utils/focusManager";
import Button from "../components2/Button";
import Layout from "../components2/Layout";
import { trackEvent } from "../analytics/segment/index";
import { skipPrehook } from '../utils';

const IntroScreen = (props) => {
  const {
    segmentKey,
    skip,
    namespace,
    closeHook,
    isPrehook,
    groupId,
    goToScreen,
    focused,
    parentFocus,
    forceFocus
  } = props;

  const signInButton = useRef(null);
  const laterButton = useRef(null);

  useEffect(() => {
    trackEvent("User Login Started");
    if (forceFocus) {
      goToScreen(null, false, true)
    }
  }, [])

  const onMaybeLaterPress = useCallback(() => skipPrehook(skip, namespace, closeHook, 
      {
        name: "User Login Started",
        data: { buttonPressed: "Maybe Later" }
      }),
    [skip, namespace, closeHook])

  const handleRemoteControlEvent = useCallback((comp, { eventType }) => {
    if (eventType === "menu") {
      onMaybeLaterPress()
    }
  }, [onMaybeLaterPress]);


  if (Platform.OS === 'android') {
    useInitialFocus(isPrehook || forceFocus ? true : focused, signInButton);
  }

  return (
    <Layout tvEventHandler={handleRemoteControlEvent} isPrehook={isPrehook}>
      <View style={styles.container}>
        <Text style={isPrehook ? styles.title : styles.subTitle}>
          {isPrehook ? 'WELCOME TO THE OLYMPIC CHANNEL' : 'Create an account to personalize your Olympic Channel experience'}
        </Text>
        <View style={styles.buttonContainer}>
          <Button
            label="Sign In / Register"
            onPress={() => goToScreen("SIGNIN")}
            preferredFocus={true}
            groupId={groupId}
            style={styles.focusContainer}
            buttonRef={signInButton}
            id={'sign-in-button'}
            nextFocusLeft={parentFocus ? parentFocus.nextFocusLeft : null}
            nextFocusDown={isPrehook ? laterButton : null}
          />
          {
            isPrehook &&
            <Button
              label="Maybe Later"
              groupId={groupId}
              onPress={onMaybeLaterPress}
              style={styles.focusContainer}
              buttonRef={laterButton}
              nextFocusUp={signInButton}
              id={'sign-in-later'}
            />
          }
        </View>
      </View>
    </Layout>
  )
}

const styles = {
  container: {
    flex: 1,
    alignItems: 'center',
    marginTop: 100
  },
  iconsContainer: {
    width: 1100,
    alignItems: 'center',
    justifyContent: 'space-between',
    flexDirection: 'row',
    marginTop: 50,
    marginBottom: 90,
  },
  title: {
    color: "#525A5C",
    fontSize: 42,
    fontWeight: 'bold',
    marginBottom: 300
  },
  subTitle: {
    color: "#525A5C",
    fontSize: 32,
  },
  altSubTitle: {
    color: "#525A5C",
    fontSize: 32,
    marginBottom: 300
  },
  buttonContainer: {
    marginTop: 20,
    width: '100%',
    height: 200,
    alignItems: 'center',
    justifyContent: 'center'
  },
  focusContainer: {
    justifyContent: 'center',
    alignItems: 'center'
  }
};

IntroScreen.displayName = 'IntroScreen';
export default IntroScreen;