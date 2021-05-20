// @flow
import React, {
  useState,
  useEffect,
  useCallback,
  useRef,
  useMemo,
} from "react";
import { useNavigation } from "@applicaster/zapp-react-native-utils/reactHooks/navigation";

import IntroScreen from "../../screens/IntroScreen";
import SignInScreen from "../../screens/SignInScreen";
import WelcomeScreen from "../../screens/WelcomeScreen";
import LoadingScreen from "../../screens/LoadingScreen";
import { localStorage } from "@applicaster/zapp-react-native-bridge/ZappStorage/LocalStorage";
import { sessionStorage } from "@applicaster/zapp-react-native-bridge/ZappStorage/SessionStorage";
import XRayLogger from "@applicaster/quick-brick-xray";

import { ScreenData, getRiversProp } from "../../Utils/Helpers";
import { BaseSubsystem, BaseCategories } from "../../Services/LoggerService";
import { getStyles } from "../../Utils/Customization";
import { getLocalizations } from "../../Utils/Localizations";

const NAMESPACE = "quick-brick-oc-login-plugin";
const TOKEN = "oc_access_token";
const USERNAME = "oc_username";
const SKIP = "skip-prehook";

let skipStatus;

const logger = new XRayLogger(BaseCategories.GENERAL, BaseSubsystem);
console.disableYellowBox = true;

const OAuth = (props) => {
  const navigator = useNavigation();
  const [screen, setScreen] = useState(ScreenData.LOADING);
  const [forceFocus, setForceFocus] = useState(false);
  const { callback, payload, rivers } = props;
  const screenId = navigator?.activeRiver?.id;

  const localizations = getRiversProp("localizations", rivers, screenId);
  const styles = getRiversProp("styles", rivers, screenId);
  const general = getRiversProp("general", rivers, screenId);

  const screenStyles = useMemo(() => getStyles(styles), [styles]);
  const screenLocalizations = getLocalizations(localizations);
  const mounted = useRef(true);
  const isPrehook = !!props?.callback;
  useEffect(() => {
    mounted.current = true;

    setupEnvironment();
    return () => {
      mounted.current = false;
    };
  }, []);

  async function setupEnvironment() {
    try {
      const accessToken = await localStorage
        .getItem(TOKEN, NAMESPACE)
        .catch((err) => console.log(err, TOKEN));
      const skipPrehook = await localStorage
        .getItem(SKIP, NAMESPACE)
        .catch((err) => console.log(err, SKIP));
      const userName = await localStorage
        .getItem(USERNAME, NAMESPACE)
        .catch((err) => console.log(err, USERNAME));

      console.log({ isPrehook, accessToken, skipPrehook });
      if (isPrehook && (accessToken || skipPrehook)) {
        skipStatus = true;
        this.props.callback({ success: true, payload: payload });
      } else if (!isPrehook && accessToken && accessToken !== "NOT_SET") {
        console.log("Logout");
        setScreen(ScreenData.LOG_OUT);
      } else {
        console.log("Intro");
        setScreen(ScreenData.INTRO);
      }
    } catch (error) {}
  }

  function goToScreen(screen, forceFocus, changeFocus) {
    if (!changeFocus) {
      setScreen(screen);
      setForceFocus(forceFocus);
    } else {
      setForceFocus(forceFocus);
    }
  }

  function renderScreen() {
    console.log({ props });
    const configuration = props;
    const screenData = props;
    const payload = props;
    const parentFocus = props;
    const focused = props;

    const getGroupId = () => {
      if (screenData) {
        return screenData.groupId;
      }
      if (payload) {
        return payload.groupId;
      }
    };

    const {
      segment_key,
      gygia_create_device_url,
      gygia_get_device_by_pin_url,
      gygia_qr_url,
      gygia_logout_url,
      gygia_support_url,
      account_url,
    } = configuration;

    const screenOptions = {
      segmentKey: segment_key,
      groupId: getGroupId(),
      isPrehook: isPrehook,
      goToScreen: goToScreen,
    };

    switch (screen) {
      case ScreenData.LOADING: {
        return <LoadingScreen {...screenOptions} />;
      }
      case ScreenData.INTRO: {
        return (
          <IntroScreen
            {...screenOptions}
            screenStyles={screenStyles}
            screenLocalizations={screenLocalizations}
            closeHook={callback}
            namespace={NAMESPACE}
            skip={SKIP}
            parentFocus={parentFocus}
            focused={focused}
            forceFocus={forceFocus}
          />
        );
      }
      case ScreenData.LOG_OUT: {
        return (
          <WelcomeScreen
            {...screenOptions}
            screenStyles={screenStyles}
            screenLocalizations={screenLocalizations}
            closeHook={callback}
            userName={this.state.userName}
            name={USERNAME}
            accessToken={this.state.accessToken}
            token={TOKEN}
            namespace={NAMESPACE}
            gygiaLogoutUrl={gygia_logout_url}
            parentFocus={parentFocus}
            focused={focused}
            forceFocus={forceFocus}
            accountUrl={account_url || "olympicchannel.com/account"}
          />
        );
      }
      case ScreenData.LOG_IN: {
        return (
          <SignInScreen
            {...screenOptions}
            screenStyles={screenStyles}
            screenLocalizations={screenLocalizations}
            closeHook={callback}
            namespace={NAMESPACE}
            skip={SKIP}
            userName={USERNAME}
            token={TOKEN}
            gygiaCreateDeviceUrl={gygia_create_device_url}
            gygiaGetDeviceByPinUrl={gygia_get_device_by_pin_url}
            gygiaQrUrl={gygia_qr_url}
            gygiaSupportUrl={gygia_support_url}
          />
        );
      }
    }
  }
  return renderScreen();
};

export default OAuth;

// export class OCLoginPluginComponent extends React.Component {
//   constructor(props) {
//     super(props);

//     console.disableYellowBox = true; // please keep this for clean debug on osTV

//     this.state = {
//       screen: "LOADING",
//       isPrehook: Boolean(this.props.callback),
//       userName: "",
//       forceFocus: false,
//       deviceId: "",
//     };

//     this.renderScreen = this.renderScreen.bind(this);
//     this.goToScreen = this.goToScreen.bind(this);
//     this.checkTokenStatus = this.checkTokenStatus.bind(this);
//   }

//   async componentDidMount() {
//     let deviceId = await sessionStorage.getItem(
//       "advertisingIdentifier",
//       "applicaster.v2"
//     );

//     //Fallback if advertisingIdentifier is not available
//     if (!deviceId) {
//       //   deviceId = uuidv4();
//       await localStorage.setItem("uuid", deviceId, NAMESPACE);
//     }

//     this.setState(
//       {
//         deviceId,
//       },
//       () => this.checkTokenStatus()
//     );
//   }

// async checkTokenStatus() {
// const accessToken = await localStorage
//   .getItem(TOKEN, NAMESPACE)
//   .catch((err) => console.log(err, TOKEN));
// const skipPrehook = await localStorage
//   .getItem(SKIP, NAMESPACE)
//   .catch((err) => console.log(err, SKIP));
// const userName = await localStorage
//   .getItem(USERNAME, NAMESPACE)
//   .catch((err) => console.log(err, USERNAME));

// const { isPrehook } = this.state;

// if (isPrehook && (accessToken || skipPrehook)) {
//   skipStatus = true;
//   this.props.callback({ success: true, payload: this.props.payload });
// } else if (!isPrehook && accessToken && accessToken !== "NOT_SET") {
//   console.log("1");
//   this.setState({
//     screen: "WELCOME",
//     userName,
//     accessToken,
//   });
// } else {
//   console.log("3");
//   this.setState({
//     screen: "INTRO",
//   });
// }
// }

// }

// export function shouldSkipPrehook() {
//   return skipStatus;
// }
