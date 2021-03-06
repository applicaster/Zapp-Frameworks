import React, { useState, useEffect } from "react";
import { Text, View, ActivityIndicator } from "react-native";

import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";
import { useNavigation } from "@applicaster/zapp-react-native-utils/reactHooks/navigation";
import PropTypes from "prop-types";

const LogoutFlow = ({
  configuration,
  screenStyles,
  screenLocalizations,
  onLogout,
}) => {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState();
  const navigator = useNavigation();

  const {
    logout_title_succeed_text,
    logout_title_fail_text,
  } = screenLocalizations;

  useEffect(() => {
    performSignOut();
    navigator.hideNavBar();
    return () => {
      navigator.showNavBar();
    };
  }, []);

  async function performSignOut() {
    await onLogout({ setError });
    setLoading(false);
  }

  const textStyle = {
    fontFamily: platformSelect({
      ios: screenStyles?.logout_title_font_ios,
      android: screenStyles?.logout_title_font_android,
      tvos: screenStyles?.logout_title_font_tvos,
      android_tv: screenStyles?.logout_title_font_android_tv,
    }),
    fontSize: screenStyles?.logout_title_font_size,
    color: screenStyles?.logout_title_font_color,
  };

  return (
    <View
      style={{
        flex: 1,
        backgroundColor: screenStyles?.logout_background_color,
        alignItems: "center",
        height: "100%",
        justifyContent: "center",
      }}
    >
      {loading === true ? (
        <ActivityIndicator color={"white"} size={"large"} />
      ) : (
        <Text style={textStyle}>
          {error ? logout_title_fail_text : logout_title_succeed_text}
        </Text>
      )}
    </View>
  );
};

export default LogoutFlow;

LogoutFlow.propTypes = {
  configuration: PropTypes.object,
  screenStyles: PropTypes.shape({
    logout_title_font_ios: PropTypes.string,
    logout_title_font_android: PropTypes.string,
    logout_title_font_tvos: PropTypes.string,
    logout_title_font_android_tv: PropTypes.string,
    logout_title_font_size: PropTypes.number,
    logout_title_font_color: PropTypes.string,
    logout_background_color: PropTypes.string,
  }),
  screenLocalizations: PropTypes.shape({
    logout_title_succeed_text: PropTypes.string,
    logout_title_fail_text: PropTypes.string,
  }),
};

LogoutFlow.defaultProps = {
  configuration: {},
  screenStyles: {},
  screenLocalizations: {},
};
