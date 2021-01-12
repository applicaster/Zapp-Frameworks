import React from "react";
import { StyleSheet, View } from "react-native";
import PropTypes from "prop-types";
import { identity } from "ramda";

import { mapKeyToStyle } from "../../../Utils/Customization";
import { useBackHandler } from "../../../Utils/Hooks";
import { useToggleNavBar } from "../../../Utils/Hooks";

import FocusableElements from "./FocusableElements";
import Title from "./Title";
import Subtitle from "./Subtitle";
import Paragraph from "./Paragraph";
import ClientLogo from "../../UIComponents/ClientLogo";

const styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: "row",
    width: "100%",
  },
  loginControls: {
    position: "relative",
    width: 556,
    marginTop: 300,
    marginRight: 250,
  },
  singUpControls: {
    marginTop: 270,
    width: 556,
  },
  contentWrapper: {
    width: 687,
    marginTop: 310,
    marginLeft: 259,
    marginRight: 168,
  },
  clientLogoView: {
    height: 100,
    width: 350,
    position: "absolute",
    top: 58,
    left: 58,
  },
  paragraphContainer: {
    marginTop: 56,
  },
});

const LoginInterface = (props) => {
  const {
    login: onLogin,
    errorMessage,
    signUp: onSignup,
    accountFlowCallback,
    screenStyles,
    screenLocalizations
  } = props;

  const hardwareBack = () => {
    accountFlowCallback(false);
  };

  useBackHandler(hardwareBack);
  useToggleNavBar();

  const titleStyles = React.useMemo(
    () => mapKeyToStyle("login_title", screenStyles),
    []
  );

  const subtitleStyles = React.useMemo(
    () => mapKeyToStyle("main_description", screenStyles),
    []
  );

  const paragraphOneStyles = React.useMemo(
    () => mapKeyToStyle("optional_instructions_1", screenStyles),
    []
  );

  const paragraphTwoStyles = React.useMemo(
    () => ({
      ...mapKeyToStyle("optional_instructions_2", screenStyles),
      marginTop: 26,
    }),
    []
  );

  return (
    <View style={styles.container}>
      <View style={styles.clientLogoView}>
        <ClientLogo imageSrc={screenStyles.client_logo} />
      </View>
      <View style={styles.contentWrapper}>
        <Title label={screenLocalizations.login_title_text} styles={titleStyles} />
        <Subtitle label={screenLocalizations.main_description_text} styles={subtitleStyles} />
        <View style={styles.paragraphContainer}>
          <Paragraph
            label={screenLocalizations.optional_instructions_1_text}
            styles={paragraphOneStyles}
          />
          <Paragraph
            label={screenLocalizations.optional_instructions_2_text}
            styles={paragraphTwoStyles}
          />
        </View>
      </View>
      <FocusableElements
        {...{
          onLogin,
          errorMessage,
          onSignup,
          screenStyles,
          loginStyles: styles.loginControls,
          signupStyles: styles.singUpControls,
          screenLocalizations
        }}
      />
    </View>
  );
};

LoginInterface.propTypes = {
  login: PropTypes.func,
  signUp: PropTypes.func,
  accountFlowCallback: PropTypes.func,
  errorMessage: PropTypes.string,
  screenStyles: PropTypes.shape({
    client_logo: PropTypes.string,
  }),
  screenLocalizations: PropTypes.shape({
    login_title_text: PropTypes.string,
    main_description_text: PropTypes.string,
    optional_instructions_1_text: PropTypes.string,
    optional_instructions_2_text: PropTypes.string,
  }),
};

LoginInterface.defaultProps = {
  login: identity,
  signUp: identity,
  accountFlowCallback: identity,
  screenStyles: {},
  screenLocalizations: {},
};

export default LoginInterface;
