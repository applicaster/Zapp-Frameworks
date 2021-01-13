import React, { useState, useEffect } from "react";
import { View, StyleSheet } from "react-native";
import PropTypes from "prop-types";

import { useDimensions } from "@applicaster/zapp-react-native-utils/reactHooks/layout";
import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";
import { inputFieldStyle } from "../../../Utils/Customization";
import { container } from "../../Styles";
import ActionButton from "../../UIComponents/Buttons/ActionButton.js";

const styles = StyleSheet.create({
  newUserButton: {
    height: 50,
    width: 250,
    alignItems: "center",
    justifyContent: "center",
    borderRadius: 50,
    alignSelf: "center",
  },
});

const LoginMobile = (props) => {
  const { width: screenWidth } = useDimensions("window");

  const { initialEmail, screenStyles, screenLocalizations } = props;

  let stillMounted = true;

  useEffect(() => {
    return () => {
      stillMounted = false;
    };
  }, []);

  useEffect(() => {
    stillMounted && setEmail(initialEmail);
  }, [initialEmail]);

  const onPressActionButton = () => {};

  return (
    <View style={{ ...container, width: screenWidth }}>
      <ActionButton
        screenStyles={screenStyles}
        title={screenLocalizations.action_button_login_text}
        onPress={onPressActionButton}
      />
    </View>
  );
};

LoginMobile.propTypes = {
  onPressActionButton: PropTypes.func,
  screenLocalizations: PropTypes.shape({
    action_button_login_text: PropTypes.string,
  }),
};

LoginMobile.defaultProps = {
  screenStyles: {},
  screenLocalizations: {},
};

export default LoginMobile;

const config = {
  clientId: 'your-client-id-generated-by-uber',
  clientSecret: 'your-client-secret-generated-by-uber',
  redirectUrl: 'com.whatever.url.you.configured.in.uber.oauth://redirect', //note: path is required
  scopes: ['profile', 'delivery'], // whatever scopes you configured in Uber OAuth portal
  serviceConfiguration: {
    authorizationEndpoint: 'https://login.uber.com/oauth/v2/authorize',
    tokenEndpoint: 'https://login.uber.com/oauth/v2/token',
    revocationEndpoint: 'https://login.uber.com/oauth/v2/revoke'
  }
};

const config = {
  clientId: '<YOUR_CLIENT_ID>',
  redirectUrl: 'com.myclientapp://myclient/redirect',
  serviceConfiguration: {
    authorizationEndpoint: '<YOUR_DOMAIN_NAME>/oauth2/authorize',
    tokenEndpoint: '<YOUR_DOMAIN_NAME>/oauth2/token',
    revocationEndpoint: '<YOUR_DOMAIN_NAME>/oauth2/revoke'
  }
};