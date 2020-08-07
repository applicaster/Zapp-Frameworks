// @flow

import React, { useState, useEffect } from "react";
import { View, ActivityIndicator, Alert, Linking } from "react-native";
import AccountComponent from "./Components/Account/Screens/AccountComponent";
import { withAppManager } from "@applicaster/quick-brick-core/App/AppStateDecorator";
import { connectToStore } from "@applicaster/zapp-react-native-redux";
import { isItemInStorage } from "./Components/Account/Utils";
import {presentAlert} from "./Components/Account/Components/FailAction"
import * as R from "ramda";

import SSOBridge from "./SSOBridge";
import { isHook } from "./Utils";
import { useNavigation } from "@applicaster/zapp-react-native-utils/reactHooks/navigation";

type Props = {
  configuration: {},
  payload: {},
  callback: ({ success: boolean, error: ?{}, payload: ?{} }) => void,
};

const overlayColor = { backgroundColor: "rgba(0,0,0,0)", flex: 1 };
const centerChildren = { alignItems: "center", justifyContent: "center" };

const getScreenGeneralStyles = R.compose(
  R.prop("general"),
  R.find(R.propEq("type", "video_subscriber_sso_apple")),
  R.values,
  R.prop("rivers")
);

const storeConnector = connectToStore((state, props) => {
  const {
    configuration: { fallback_login_plugin_id },
  } = props;

  let loginPlugin = state.plugins.find(
    ({ type, identifier }) =>
      type === "login" && identifier === fallback_login_plugin_id
  );

  if (!loginPlugin) {
    loginPlugin = state.plugins.find(({ type }) => type === "login");
  }

  const values = Object.values(state.rivers);

  // eslint-disable-next-line array-callback-return,consistent-return
  const plugin = values.find((item) => {
    if (item && item.type) {
      return item.type === loginPlugin.identifier;
    }
  });

  return { plugin };
});

const SSOProvider = (props) => {
  const PluginInvocationType = {
    UNDEFINED: "Undefined",
    SSO_HOOK: "SSOHook",
    USER_ACCOUNT: "UserAccount",
  };

  const [pluginInvocationType, setPluginInvocationType] = useState(
    PluginInvocationType.UNDEFINED
  );

  const navigator = useNavigation();
  let stillMounted = true;

  useEffect(() => {
    setupEnviroment();

    return () => {
      stillMounted = false;
    };
  }, []);

  useEffect(() => {
    if (pluginInvocationType === PluginInvocationType.SSO_HOOK) {
      const { callback, payload, plugin, configuration } = props;
      const { fallback_login_plugin_id } = configuration;
      // Will be called once, when component finish logic
      console.log({
        props,
        localization: navigator.activeRiver,
        getScreenGeneralStyles: getScreenGeneralStyles(props),
      });

      SSOBridge.signIn()
        .then(async function (result) {
          if (!result) {
            let applicasterToken = await isItemInStorage(
              "idToken",
              fallback_login_plugin_id
            );

            if (!applicasterToken) {
              presentAlert(getScreenGeneralStyles(props))
            }
          }

          callback({ success: result, error: null, payload });
        })
        .catch((error) => {
          callback({ success: false, error, payload });
        });
    }
  }, [pluginInvocationType]);

  const setupEnviroment = async () => {
    if (isHook(navigator)) {
      stillMounted && setPluginInvocationType(PluginInvocationType.SSO_HOOK);
    } else {
      stillMounted &&
        setPluginInvocationType(PluginInvocationType.USER_ACCOUNT);
    }
  };

  const renderFlow = () => {
    if (pluginInvocationType === PluginInvocationType.USER_ACCOUNT) {
      return <AccountComponent navigator={navigator}  screenGeneralStyles={getScreenGeneralStyles(props)} { ...props} />;
    } else {
      return <ActivityIndicator color="white" size="large" />;
    }
  };

  return <View style={[overlayColor, centerChildren]}>{renderFlow()}</View>;
};
export default withAppManager(storeConnector(SSOProvider));
