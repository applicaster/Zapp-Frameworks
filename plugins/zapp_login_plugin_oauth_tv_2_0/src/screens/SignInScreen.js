import React, { useEffect, useState, useRef, useCallback } from "react";
import { View, Text, Platform, ActivityIndicator } from "react-native";
import axios from "axios";
import { useInitialFocus } from "@applicaster/zapp-react-native-utils/focusManager";
import { localStorage } from "@applicaster/zapp-react-native-bridge/ZappStorage/LocalStorage";
import { trackEvent, identify } from "../analytics/segment/index";
import Button from "../components2/Button";
import QRCode from "../components2/QRCode";
import Layout from "../components2/Layout";
import { skipPrehook } from "../utils";

const HEARBEAT_INTERVAL = 10000;

const SignInScreen = (props) => {
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
    forceFocus,
  } = props;

  const handleRemoteControlEvent = useCallback(
    (comp, event) => {
      const { eventType } = event;

      if (isPrehook && eventType === "menu") {
        goToScreen("INTRO");
      }
    },
    [goToScreen, isPrehook]
  );

  const [devicePinCode, setDevicePinCode] = useState("");
  const [loading, setLoading] = useState(true);

  const skipButton = useRef(null);
  useInitialFocus(Platform.OS === "android", skipButton);

  const getSignInStatus = useCallback(() => {
    axios
      .get(`${props.gygiaGetDeviceByPinUrl}/${devicePinCode}`, {
        headers: {
          accept: "application/json",
        },
      })
      .then(async (response) => {
        if (response.data.access_token) {
          const { access_token, firstname } = response.data;

          identify(
            firstname,
            response.data.userId,
            devicePinCode,
            "Sign In Page"
          );

          await localStorage.setItem(
            props.token,
            access_token,
            props.namespace
          );

          await localStorage.setItem(
            props.userName,
            firstname,
            props.namespace
          );

          if (props.isPrehook) {
            trackEvent("Signed In");
            props.closeHook({ success: true });
          } else {
            props.goToScreen("WELCOME", true);
            trackEvent("Signed In", { userName: access_token });
          }
        }
      })
      .catch((err) => {
        console.log(err);
        trackEvent("Login Error");
      });
  }, [props, devicePinCode]);

  useEffect(() => {
    if (devicePinCode) {
      const heartbeat = setInterval(getSignInStatus, HEARBEAT_INTERVAL);
      return () => clearInterval(heartbeat);
    }
  }, [devicePinCode]);

  useEffect(() => {
    const { gygiaCreateDeviceUrl, segmentKey, deviceId } = props;

    trackEvent("Waiting Page");
    axios
      .post(
        `${gygiaCreateDeviceUrl}`,
        {
          deviceId: deviceId,
        },
        {
          headers: {
            accept: "application/json",
            "Content-Type": "application/json",
          },
        }
      )
      .then((response) => {
        setDevicePinCode(response.data.devicePinCode);
        setLoading(false);
      })
      .catch((err) => console.log(err));
  }, []);

  const onMaybeLaterPress = useCallback(
    () =>
      skipPrehook(skip, namespace, closeHook, {
        name: "User Sign in Skipped",
        data: { buttonPressed: "Skip" },
      }),
    [skip, namespace, closeHook]
  );

  return (
    <Layout tvEventHandler={handleRemoteControlEvent} isPrehook={isPrehook}>
      <View style={styles.container}>
        <Text style={styles.title}>
          SIGN IN INTO YOUR OLYMPIC CHANNEL ACCOUNT
        </Text>
        <View style={styles.columnsContainer}>
          <View style={styles.leftColumn}>
            <Text style={styles.text} adjustsFontSizeToFit>
              Go to:
            </Text>
            <Text style={[styles.text, styles.url]} adjustsFontSizeToFit>
              account.olympicchannel.com
            </Text>
            <Text
              style={[styles.text, { marginBottom: 30 }]}
              adjustsFontSizeToFit
            >
              Enter the activation code below
            </Text>
            {loading ? (
              <View style={styles.pinCodeSpinner}>
                <ActivityIndicator size="small" color="#525A5C" />
              </View>
            ) : (
              <Text style={styles.pinCode} adjustsFontSizeToFit>
                {devicePinCode}
              </Text>
            )}
          </View>
          <View style={styles.rightColumn}>
            {loading ? (
              <View style={styles.loadContainer}>
                <ActivityIndicator size="large" color="#525A5C" />
              </View>
            ) : (
              <QRCode url={`${props.gygiaQrUrl}${devicePinCode}`} />
            )}
          </View>
        </View>
        <View style={styles.bottomText}>
          <Text style={styles.text}>
            If you need support, please visit{" "}
            <Text style={[styles.text, { color: "#525A5C", marginLeft: 32 }]}>
              {" "}
              olympicchannel.com/contact-us
            </Text>
          </Text>
        </View>
        {isPrehook && (
          <Button
            label="Maybe Later"
            onPress={onMaybeLaterPress}
            preferredFocus={true}
            groupId={groupId}
            style={styles.focusContainer}
            buttonRef={skipButton}
            id={"skip-sign-in"}
          />
        )}
      </View>
    </Layout>
  );
};

const styles = {
  container: {
    flex: 1,
    alignItems: "center",
  },
  title: {
    color: "#525A5C",
    fontSize: 42,
    fontWeight: "bold",
    marginBottom: 110,
  },
  text: {
    color: "#525A5C",
    fontSize: 32,
    marginBottom: 20,
  },
  url: {
    fontWeight: "bold",
    fontSize: 36,
    marginBottom: 60,
    color: "#525A5C",
  },
  columnsContainer: {
    width: 1110,
    alignItems: "center",
    justifyContent: "center",
    flexDirection: "row",
    paddingTop: 30,
  },
  bottomText: {
    width: 1110,
    alignItems: "center",
    justifyContent: "center",
    paddingTop: 80,
  },
  leftColumn: {
    flex: 1,
    justifyContent: "center",
    alignItems: "flex-start",
    borderRightColor: "#979797",
    borderRightWidth: 2,
    minHeight: 330,
  },
  rightColumn: {
    flex: 1,
    justifyContent: "center",
    alignItems: "flex-end",
    borderLeftColor: "#979797",
    borderLeftWidth: 2,
    minHeight: 330,
  },
  loadContainer: {
    width: 300,
    height: 300,
    justifyContent: "center",
    alignItems: "center",
  },
  pinCode: {
    fontSize: 72,
    color: "#525A5C",
    fontWeight: "bold",
  },
  pinCodeSpinner: {
    width: 500,
    alignItems: "center",
    justifyContent: "center",
  },
  focusContainer: {
    justifyContent: "center",
    alignItems: "center",
  },
};

SignInScreen.displayName = "SignInScreen";
export default SignInScreen;
