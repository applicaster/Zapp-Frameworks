import React, { useEffect, useState, useRef, useCallback } from "react";
import { View, Text, Platform, ActivityIndicator } from "react-native";
import axios from "axios";
import { useInitialFocus } from "@applicaster/zapp-react-native-utils/focusManager";
import { localStorage } from "@applicaster/zapp-react-native-bridge/ZappStorage/LocalStorage";
import Button from "../components2/Button";
import QRCode from "../components2/QRCode";
import Layout from "../components2/Layout";
import { skipPrehook } from "../utils";
import { mapKeyToStyle } from "../Utils/Customization";

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
    screenStyles,
    screenLocalizations,
  } = props;

  const { activity_indicator_color, line_separator_color } = screenStyles;

  const styles = {
    container: {
      flex: 1,
      alignItems: "center",
    },
    title: {
      ...mapKeyToStyle("title", screenStyles),
      fontWeight: "bold",
      marginBottom: 110,
    },
    text: {
      ...mapKeyToStyle("text", screenStyles),
      marginBottom: 20,
    },
    url: {
      ...mapKeyToStyle("text_url", screenStyles),
      fontWeight: "bold",
      marginBottom: 60,
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
      borderRightColor: line_separator_color,
      borderRightWidth: 2,
      minHeight: 330,
    },
    rightColumn: {
      flex: 1,
      justifyContent: "center",
      alignItems: "flex-end",
      borderLeftColor: line_separator_color,
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
      ...mapKeyToStyle("text_code", screenStyles),
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

  const {
    sing_in_later,
    sing_in_title,
    sign_in_go_to_title,
    sign_in_pin_url,
    sign_in_activation_code_title,
    sign_in_support_title,
    sign_in_support_link,
  } = screenLocalizations;

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
            props.closeHook({ success: true });
          } else {
            props.goToScreen("WELCOME", true);
          }
        }
      })
      .catch((err) => {
        console.log(err);
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
    <Layout
      tvEventHandler={handleRemoteControlEvent}
      screenStyles={screenStyles}
      isPrehook={isPrehook}
    >
      <View style={styles.container}>
        <Text style={styles.title}>{sing_in_title}</Text>
        <View style={styles.columnsContainer}>
          <View style={styles.leftColumn}>
            <Text style={styles.text} adjustsFontSizeToFit>
              {sign_in_go_to_title}
            </Text>
            <Text style={[styles.text, styles.url]} adjustsFontSizeToFit>
              {sign_in_pin_url}
            </Text>
            <Text
              style={[styles.text, { marginBottom: 30 }]}
              adjustsFontSizeToFit
            >
              {sign_in_activation_code_title}
            </Text>
            {loading ? (
              <View style={styles.pinCodeSpinner}>
                <ActivityIndicator
                  size="small"
                  color={activity_indicator_color}
                />
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
                <ActivityIndicator
                  size="large"
                  color={activity_indicator_color}
                />
              </View>
            ) : (
              <QRCode url={`${props.gygiaQrUrl}${devicePinCode}`} />
            )}
          </View>
        </View>
        <View style={styles.bottomText}>
          <Text style={styles.text}>
            {sign_in_support_title}
            <Text style={[styles.text, { color: "#525A5C", marginLeft: 32 }]}>
              {` ${sign_in_support_link}`}
            </Text>
          </Text>
        </View>
        {isPrehook && (
          <Button
            screenStyles={screenStyles}
            label={sing_in_later}
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

SignInScreen.displayName = "SignInScreen";
export default SignInScreen;
