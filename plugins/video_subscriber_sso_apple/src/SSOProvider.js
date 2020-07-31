// @flow

import React, { useState, useEffect } from "react";
import { View, ActivityIndicator } from "react-native";
import AccountComponent from "./Components/Account/Screens/AccountComponent";
import { withAppManager } from "@applicaster/quick-brick-core/App/AppStateDecorator";

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

const SSOProvider = (props) => {
  const SSOProviderType = {
    UNDEFINED: "Undefined",
    SSO_HOOK: "SSOHook",
    USER_ACCOUNT: "UserAccount",
  };

  const [providerType, setProviderType] = useState(SSOProviderType.UNDEFINED);
  const navigator = useNavigation();
  let stillMounted = true;

  useEffect(() => {
    setupEnviroment();
    return () => {
      stillMounted = false;
    };
  }, []);

  useEffect(() => {
    if (providerType === SSOProviderType.SSO_HOOK) {
      const { callback, payload } = props;
      // Will be called once, when component finish logic
      SSOBridge.signIn()
        .then((result) => {
          callback({ success: result, error: null, payload });
        })
        .catch((error) => {
          callback({ success: false, error, payload });
        });
    }
  }, [providerType]);

  const setupEnviroment = async () => {
    if (isHook(navigator)) {
      stillMounted && setProviderType(SSOProviderType.SSO_HOOK);
    } else {
      stillMounted && setProviderType(SSOProviderType.USER_ACCOUNT);
    }
  };

  const renderFlow = () => {
    if (providerType === SSOProviderType.USER_ACCOUNT) {
      return <AccountComponent navigator={navigator} {...props} />;
    } else {
      return <ActivityIndicator color="white" size="large" />;
    }
  };

  return <View style={[overlayColor, centerChildren]}>{renderFlow()}</View>;
};
export default withAppManager(SSOProvider);
