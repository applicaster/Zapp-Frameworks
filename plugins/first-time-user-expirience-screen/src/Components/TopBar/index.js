import React, { useState, useEffect, useCallback, useMemo } from "react";
import { Platform, View, ViewProps } from "react-native";
import Button from "../Buttons/Button";
import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";
import {
  createLogger,
  BaseSubsystem,
  BaseCategories,
} from "../../Services/LoggerService";

const logger = createLogger({
  subsystem: BaseSubsystem,
  category: BaseCategories.GENERAL,
});

export default function TopBar({
  screenStyles,
  screenLocalizations,
  onBack,
  onNext,
  onClose,
  isLastScreen = false,
  isFistScreen = false,
}) {
  console.log({ screenLocalizations });
  const {
    back_button_text,
    next_button_text,
    sign_in_button_text,
    close_button_text,
  } = screenLocalizations;

  const TextStyleNavigationButtons = {
    textAlign: "center",
    fontFamily: platformSelect({
      ios: screenStyles?.navigation_bar_button_font_ios,
      android: screenStyles?.navigation_bar_button_font_android,
    }),
    fontSize: screenStyles?.navigation_bar_button_font_size,
    color: screenStyles?.navigation_bar_button_font_color,
  };

  const TextStylSignInButtons = {
    textAlign: "center",
    fontFamily: platformSelect({
      ios: screenStyles?.sign_in_bar_button_font_ios,
      android: screenStyles?.sign_in_bar_button_font_android,
    }),
    fontSize: screenStyles?.sign_in_bar_button_font_size,
    color: screenStyles?.sign_in_bar_button_font_color,
  };

  const ContainerStyle = {
    backgroundColor: screenStyles?.bottom_bar_background_color,
    height: screenStyles?.bottom_bar_height,
    flexDirection: "row",
    paddingLeft: 5,
    paddingRight: 5,
    justifyContent: "center",
    alignItems: "center",
  };

  const leftButtonContainer = {
    flex: 1,
    height: screenStyles?.navigation_bar_button_height,
    justifyContent: "center",
    alignItems: "center",
    borderRadius: Number(screenStyles?.navigation_bar_button_radius),
    borderColor: screenStyles?.navigation_bar_button_border_color,
    borderWidth: screenStyles?.navigation_bar_button_border_size,
    backgroundColor: screenStyles?.navigation_bar_button_background_color,
  };

  const rightButtonContainer = {
    flex: 1,
    height: screenStyles?.navigation_bar_button_height,
    justifyContent: "center",
    alignItems: "center",
    // padding: 5,
    // position: "absolute",
    borderRadius: Number(screenStyles?.navigation_bar_button_radius),
    borderColor: screenStyles?.navigation_bar_button_border_color,
    borderWidth: screenStyles?.navigation_bar_button_border_size,
    backgroundColor: screenStyles?.navigation_bar_button_background_color,
  };
  const signInButtonContainer = {
    justifyContent: "center",
    alignItems: "center",
    flex: 2,
    height: screenStyles?.sign_in_bar_button_height,
    marginHorizontal: 15,
    borderRadius: Number(screenStyles?.sign_in_bar_button_radius),
    borderColor: screenStyles?.sign_in_bar_button_border_color,
    borderWidth: screenStyles?.sign_in_bar_button_border_size,
    backgroundColor: screenStyles?.sign_in_bar_button_background_color,
  };

  return (
    <View style={ContainerStyle}>
      <Button
        styles={leftButtonContainer}
        textStyle={TextStyleNavigationButtons}
        title={back_button_text}
        onPress={onBack}
        disabled={isFistScreen}
        hidden={screenStyles?.is_bar_back_button_hidden}
      />
      <Button
        styles={signInButtonContainer}
        textStyle={TextStylSignInButtons}
        title={sign_in_button_text}
        onPress={onBack}
        disabled={isFistScreen}
        hidden={screenStyles?.is_bar_login_button_hidden}
      />
      <Button
        styles={rightButtonContainer}
        textStyle={TextStyleNavigationButtons}
        title={isLastScreen ? close_button_text : next_button_text}
        onPress={isLastScreen ? onClose : onNext}
        disabled={false}
        hidden={screenStyles?.is_bar_next_button_hidden}
      />
    </View>
  );
}
