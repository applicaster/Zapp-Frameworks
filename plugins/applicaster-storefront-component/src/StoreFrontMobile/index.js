import React from "react";
import PropTypes from "prop-types";
import { SafeAreaView, StyleSheet, Dimensions } from "react-native";
import StoreFrontContainer from "./StoreFrontContainer";
import NavbarComponent from "../UIComponents/NavbarComponent";

import Footer from "../UIComponents/Footer";

const { height, width } = Dimensions.get("window");

const styles = StyleSheet.create({
  container: {
    height,
    width,
    paddingBottom: 15,
  },
});

const StoreFrontMobile = (props) => {
  const { onHandleBack, screenStyles, screenLocalizations } = props;

  const {
    payment_screen_background: screenBackground = "",
    client_logo: logoUrl = "",
    close_button: buttonUrl = "",
  } = screenStyles;
  return (
    <SafeAreaView
      style={[styles.container, { backgroundColor: screenBackground }]}
    >
      <NavbarComponent
        buttonAction={onHandleBack}
        logoUrl={logoUrl}
        buttonUrl={buttonUrl}
      />
      <StoreFrontContainer {...props} />
      <Footer
        screenStyles={screenStyles}
        screenLocalizations={screenLocalizations}
      />
    </SafeAreaView>
  );
};

StoreFrontMobile.propTypes = {
  onHandleBack: PropTypes.func,
  screenStyles: PropTypes.object,
  screenLocalizations: PropTypes.object,
};

StoreFrontMobile.defaultProps = {
  screenStyles: {},
  screenLocalizations: {},
};

export default StoreFrontMobile;
