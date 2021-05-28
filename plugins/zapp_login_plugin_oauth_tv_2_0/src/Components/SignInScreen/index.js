import React, {
  useEffect,
  useState,
  useRef,
  useCallback,
  useLayoutEffect,
} from "react";
import { View, Text, Platform, ActivityIndicator } from "react-native";
import { useInitialFocus } from "@applicaster/zapp-react-native-utils/focusManager";
import { saveDataToStorages } from "../../Services/StorageService";
import {
  createLogger,
  BaseSubsystem,
  BaseCategories,
} from "../../Services/LoggerService";
import Button from "../Button";
import QRCode from "../QRCode";
import Layout from "../Layout";
import { mapKeyToStyle } from "../../Utils/Customization";
import { getDevicePin, getDeviceToken } from "../../Services/OAuth2Service";
import { ScreenData } from "../Login/utils";

const logger = createLogger({
  subsystem: BaseSubsystem,
  category: BaseCategories.GENERAL,
});
function SignInScreen(props) {
  const {
    isPrehook,
    groupId,
    goToScreen,
    screenStyles,
    screenLocalizations,
    configuration,
    callback,
    finishHook,
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

  const clearAllTimeouts = useCallback(() => {
    clearSignInStatusTimeout();
    clearLoadDeviceDataTimeout();
  }, [signInStatusAutoupdate, loadDeviceDataTimeout]);

  const clearSignInStatusTimeout = useCallback(() => {
    signInStatusAutoupdateTimeout &&
      clearTimeout(signInStatusAutoupdateTimeout);
    setSignInStatusAutoupdateTimeout(null);
    setSignInStatusAutoupdate(false);
  }, [signInStatusAutoupdate]);

  const clearLoadDeviceDataTimeout = useCallback(() => {
    loadDeviceDataTimeout && clearTimeout(loadDeviceDataTimeout);
    setLoadDeviceDataTimeout(null);
  }, [loadDeviceDataTimeout]);

  const handleRemoteControlEvent = useCallback(
    (comp, event) => {
      const { eventType } = event;

      if (isPrehook && eventType === "menu") {
        logger.debug({
          message: `User handle menu button`,
          data: {
            is_prehook: isPrehook,
            event_type: eventType,
          },
        });
        clearAllTimeouts();
        goToScreen(ScreenData.INTRO);
      }
    },
    [signInStatusAutoupdate, goToScreen, isPrehook, loadDeviceDataTimeout]
  );

  const [deviceData, setDeviceData] = useState(null);
  const [signInStatusAutoupdate, setSignInStatusAutoupdate] = useState(false);
  const [
    signInStatusAutoupdateTimeout,
    setSignInStatusAutoupdateTimeout,
  ] = useState(null);
  const [loadDeviceDataTimeout, setLoadDeviceDataTimeout] = useState(null);
  const [loading, setLoading] = useState(true);

  const mounted = useRef(true);

  const skipButton = useRef(null);
  useInitialFocus(Platform.OS === "android", skipButton);

  const getSignInStatus = useCallback(async () => {
    console.log({ signInStatusAutoupdate, deviceData });

    try {
      const data = await getDeviceToken(configuration, deviceData?.device_code);
      console.log({ data });
      if (data?.access_token) {
        logger.debug({
          message: `Get device token complete`,
          data: {
            data,
            access_token: data?.access_token,
            signInStatusAutoupdateTimeout,
          },
        });
        setSignInStatusAutoupdate(false);
        await saveDataToStorages(data);

        if (props.isPrehook) {
          finishHook();
        } else {
          props.goToScreen(ScreenData.LOG_OUT, true);
        }
      } else {
        logger.debug({
          message: `Get device token complete, access token not exists`,
          data: {
            data,
          },
        });
      }
    } catch (error) {
      const data = {
        error: error,
        deviceData,
        signInStatusAutoupdate,
        interval: deviceData?.interval * 1000,
      };
      if (mounted.current && signInStatusAutoupdate) {
        if (signInStatusAutoupdateTimeout) {
          clearTimeout(signInStatusAutoupdateTimeout);
        }
        const timeOut = setTimeout(
          getSignInStatus,
          deviceData?.interval * 1000
        );
        console.log({ timeOut });
        setSignInStatusAutoupdateTimeout(timeOut);

        logger.info({
          message: `Get token failed, no data, checking again getSignInStatus:`,
          data,
        });
      } else {
        logger.info({
          message: `Get token failed, no data, autoupdate canceled`,
          data,
        });
      }
    }
  }, [
    deviceData,
    signInStatusAutoupdate,
    signInStatusAutoupdateTimeout,
    callback,
  ]);

  useLayoutEffect(() => {
    loadDeviceData();
    mounted.current = true;
    return () => {
      mounted.current = false;
    };
  }, []);

  useLayoutEffect(() => {
    console.log("useLayoutEffect", { signInStatusAutoupdate });
    if (signInStatusAutoupdate && signInStatusAutoupdateTimeout === null) {
      getSignInStatus();
    }
  }, [signInStatusAutoupdate]);

  useLayoutEffect(() => {
    if (deviceData) {
      setLoading(false);
      logger.debug({
        message: `New device data, updated`,
        data: {
          device_data: deviceData,
        },
      });
      applySignInStatusCheck();
    }
  }, [deviceData]);

  const applySignInStatusCheck = useCallback(() => {
    setSignInStatusAutoupdate(true);
    console.log("applySignInStatusCheck", {
      signInStatusAutoupdate,
      deviceData,
    });

    const timeout = setTimeout(loadDeviceData, deviceData?.expires_in * 1000);
    setLoadDeviceDataTimeout(timeout);
  }, [signInStatusAutoupdate, deviceData, loadDeviceDataTimeout]);

  const loadDeviceData = useCallback(async () => {
    try {
      clearAllTimeouts();

      const result = await getDevicePin(configuration);

      logger.debug({
        message: `loadDeviceData: completed`,
        data: {
          device_data: result,
        },
      });
      setDeviceData(result);
    } catch (error) {
      logger.error({
        message: `loadDeviceData: failed`,
        data: {
          error: error,
        },
      });
    }
  }, [signInStatusAutoupdate, deviceData, loadDeviceDataTimeout]);

  const onMaybeLaterPress = useCallback(() => {
    clearAllTimeouts();
    finishHook();
  }, [loadDeviceDataTimeout, signInStatusAutoupdate]);
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
}

SignInScreen.displayName = "SignInScreen";
export default SignInScreen;
