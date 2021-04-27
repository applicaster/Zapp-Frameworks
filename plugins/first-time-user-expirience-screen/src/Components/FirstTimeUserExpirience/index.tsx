import React, { useState, useEffect, useCallback } from "react";
import { Platform, View } from "react-native";
// https://github.com/testshallpass/react-native-dropdownalert#usage
import DropdownAlert from "react-native-dropdownalert";
import { isWebBasedPlatform } from "../../Utils/Platform";
import * as R from "ramda";
import { useNavigation } from "@applicaster/zapp-react-native-utils/reactHooks/navigation";


import { getStyles, isHomeScreen } from "../../Utils/Customization";
import { isHook } from "../../Utils/UserAccount";
import {
  createLogger,
  BaseSubsystem,
  BaseCategories,
} from "../../Services/LoggerService";

const logger = createLogger({
  subsystem: BaseSubsystem,
  category: BaseCategories.GENERAL,
});

const getRiversProp = (key, rivers = {}, screenId = "") => {
  const getPropByKey = R.compose(
    R.prop(key),
    R.find(R.propEq("id", screenId)),
    R.values
  );

  return getPropByKey(rivers);
};

const FirstTimeUserExpirience = (props) => {
  const navigator = useNavigation();
  const screenId = navigator?.activeRiver?.id;

  const { callback, payload, rivers } = props;
  const localizations = getRiversProp("localizations", rivers, screenId);
  const styles = getRiversProp("styles", rivers, screenId);

  const screenStyles = getStyles(styles);
  const screenLocalizations = getLocalizations(localizations);

  const {
    configuration: {},
  } = props;


  useEffect(() => {
    navigator.hideNavBar();
    navigator.hideBottomBar();

    setupEnvironment();
    return () => {
      navigator.showNavBar();
      navigator.showBottomBar();
    };
  }, []);

  async function setupEnvironment() {}

  return (
    <View
      style={{
        flex: 1,
        backgroundColor: screenStyles?.background_color,
      }}
    ></View>
  );
};
export default FirstTimeUserExpirience;
