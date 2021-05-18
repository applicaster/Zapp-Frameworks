// @flow
import * as React from "react";
import IntroScreen from "../../screens/IntroScreen";
import SignInScreen from "../../screens/SignInScreen";
import WelcomeScreen from "../../screens/WelcomeScreen";
import LoadingScreen from "../../screens/LoadingScreen";
import LegalScreen from "../../screens/LegalScreen";
import { localStorage } from "@applicaster/zapp-react-native-bridge/ZappStorage/LocalStorage";
import { sessionStorage } from "@applicaster/zapp-react-native-bridge/ZappStorage/SessionStorage";
// import { uuidv4 } from "./utils";

const NAMESPACE = "quick-brick-oc-login-plugin";
const TOKEN = "oc_access_token";
const USERNAME = "oc_username";
const SKIP = "skip-prehook";

let skipStatus;

export class OCLoginPluginComponent extends React.Component {
  constructor(props) {
    super(props);

    console.disableYellowBox = true; // please keep this for clean debug on osTV

    this.state = {
      screen: "LOADING",
      isPrehook: Boolean(this.props.callback),
      userName: "",
      forceFocus: false,
      deviceId: "",
    };

    this.renderScreen = this.renderScreen.bind(this);
    this.goToScreen = this.goToScreen.bind(this);
    this.checkTokenStatus = this.checkTokenStatus.bind(this);
  }

  async componentDidMount() {
    let deviceId = await sessionStorage.getItem(
      "advertisingIdentifier",
      "applicaster.v2"
    );

    //Fallback if advertisingIdentifier is not available
    if (!deviceId) {
      //   deviceId = uuidv4();
      await localStorage.setItem("uuid", deviceId, NAMESPACE);
    }

    this.setState(
      {
        deviceId,
      },
      () => this.checkTokenStatus()
    );
  }

  async checkTokenStatus() {
    const accessToken = await localStorage
      .getItem(TOKEN, NAMESPACE)
      .catch((err) => console.log(err, TOKEN));
    const skipPrehook = await localStorage
      .getItem(SKIP, NAMESPACE)
      .catch((err) => console.log(err, SKIP));
    const userName = await localStorage
      .getItem(USERNAME, NAMESPACE)
      .catch((err) => console.log(err, USERNAME));

    const { isPrehook } = this.state;

    if (isPrehook && (accessToken || skipPrehook)) {
      skipStatus = true;
      this.props.callback({ success: true, payload: this.props.payload });
    } else if (!isPrehook && accessToken && accessToken !== "NOT_SET") {
      this.setState({
        screen: "WELCOME",
        userName,
        accessToken,
      });
    } else if (isPrehook && !accessToken) {
      this.setState({
        screen: "LEGAL",
      });
    } else {
      this.setState({
        screen: "INTRO",
      });
    }
  }

  goToScreen(screen, forceFocus, changeFocus) {
    if (!changeFocus) {
      this.setState({
        screen,
        forceFocus,
      });
    } else {
      this.setState({
        forceFocus,
      });
    }
  }

  renderScreen(screen) {
    const {
      configuration,
      screenData,
      payload,
      callback,
      parentFocus,
      focused,
    } = this.props;

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
      legal_content,
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
      isPrehook: this.state.isPrehook,
      goToScreen: this.goToScreen,
    };

    switch (screen) {
      case "LOADING": {
        return <LoadingScreen {...screenOptions} />;
      }
      case "LEGAL": {
        return (
          <LegalScreen
            {...screenOptions}
            legalContent={legal_content}
            parentFocus={parentFocus}
            focused={focused}
          />
        );
      }
      case "INTRO": {
        return (
          <IntroScreen
            {...screenOptions}
            closeHook={callback}
            namespace={NAMESPACE}
            skip={SKIP}
            parentFocus={parentFocus}
            focused={focused}
            forceFocus={this.state.forceFocus}
          />
        );
      }
      case "WELCOME": {
        return (
          <WelcomeScreen
            {...screenOptions}
            closeHook={callback}
            userName={this.state.userName}
            name={USERNAME}
            accessToken={this.state.accessToken}
            token={TOKEN}
            namespace={NAMESPACE}
            gygiaLogoutUrl={gygia_logout_url}
            parentFocus={parentFocus}
            focused={focused}
            forceFocus={this.state.forceFocus}
            accountUrl={account_url || "olympicchannel.com/account"}
          />
        );
      }
      case "SIGNIN": {
        return (
          <SignInScreen
            {...screenOptions}
            closeHook={callback}
            namespace={NAMESPACE}
            skip={SKIP}
            userName={USERNAME}
            token={TOKEN}
            gygiaCreateDeviceUrl={gygia_create_device_url}
            gygiaGetDeviceByPinUrl={gygia_get_device_by_pin_url}
            gygiaQrUrl={gygia_qr_url}
            gygiaSupportUrl={gygia_support_url}
            deviceId={this.state.deviceId}
          />
        );
      }
    }
  }
  render() {
    return this.renderScreen(this.state.screen);
  }
}

export function shouldSkipPrehook() {
  return skipStatus;
}
