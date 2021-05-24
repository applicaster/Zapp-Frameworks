import React, {
  useEffect,
  useState,
  useRef,
  useCallback,
  useLayoutEffect,
} from "react";
import { View, Text, Platform, ActivityIndicator } from "react-native";
import { useInitialFocus } from "@applicaster/zapp-react-native-utils/focusManager";
import { localStorage } from "@applicaster/zapp-react-native-bridge/ZappStorage/LocalStorage";
import Button from "../../Components/Button";
import QRCode from "../../Components/QRCode";
import Layout from "../../Components/Layout";
import { skipPrehook } from "../../utils";
import { mapKeyToStyle } from "../../Utils/Customization";
import { getDevicePin, getDeviceToken } from "../../Services/OAuth2Service";
import { ScreenData } from "../../Utils/Helpers";

const SignInScreen = (props) => {
  const {
    skip,
    namespace,
    closeHook,
    isPrehook,
    groupId,
    goToScreen,
    screenStyles,
    screenLocalizations,
    configuration,
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
    sign_in_activation_code_title,
    sign_in_support_title,
    sign_in_support_link,
  } = screenLocalizations;

  const handleRemoteControlEvent = useCallback(
    (comp, event) => {
      const { eventType } = event;

      if (isPrehook && eventType === "menu") {
        goToScreen(ScreenData.INTRO);
      }
    },
    [goToScreen, isPrehook]
  );

  const [deviceData, setDeviceData] = useState(null);
  const [signInStatusUpdater, setSignInStatusUpdater] = useState(null);
  const [loading, setLoading] = useState(true);

  const skipButton = useRef(null);
  useInitialFocus(Platform.OS === "android", skipButton);

  const getSignInStatus = useCallback(async () => {
    try {
      const data = await getDeviceToken(configuration, deviceData?.device_code);
      console.log("getSignInStatus", { data });
      if (data?.access_token) {
        const { access_token } = data;
        clearStatusUpdater();
        await localStorage.setItem(props.token, access_token, props.namespace);
        console.log("I am in !!!!", { props });
        if (props.isPrehook) {
          props.closeHook({ success: true });
        } else {
          props.goToScreen(ScreenData.LOG_OUT, true);
        }
      }
    } catch (error) {
      console.log({ error });
    }
  }, [deviceData, signInStatusUpdater]);

  useEffect(() => {
    console.log("Will try to load", { props });
    loadDeviceData();
  }, []);

  useLayoutEffect(() => {
    if (deviceData) {
      setLoading(false);
      const data = setInterval(getSignInStatus, deviceData?.interval * 1000);
      console.log({ data });
      setSignInStatusUpdater(data);
      setTimeout(loadDeviceData, deviceData?.expires_in * 1000);
      return () => clearStatusUpdater();
    }
  }, [deviceData]);

  function clearStatusUpdater() {
    clearInterval(signInStatusUpdater);
    setSignInStatusUpdater(null);
  }

  async function loadDeviceData() {
    try {
      const result = await getDevicePin(configuration);
      setDeviceData(result);
    } catch (error) {
      //Logs and fail
    }
  }

  const onMaybeLaterPress = useCallback(
    () =>
      skipPrehook(skip, namespace, closeHook, {
        name: "User Sign in Skipped",
        data: { buttonPressed: "Skip" },
      }),
    [skip, namespace, closeHook]
  );
  console.log({ deviceData });
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
              {deviceData?.verification_uri}
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
                {deviceData?.user_code}
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
            ) : deviceData?.verification_uri ? (
              <QRCode url={deviceData?.verification_uri} />
            ) : null}
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
