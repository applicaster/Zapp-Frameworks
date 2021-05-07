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
    fontFamily: platformSelect({
      ios: screenStyles?.navigation_bar_button_font_ios,
      android: screenStyles?.navigation_bar_button_font_android,
    }),
    fontSize: screenStyles?.navigation_bar_button_font_size,
    color: screenStyles?.navigation_bar_button_font_color,
  };

  const TextStylSignInButtons = {
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
    justifyContent: "center",
  };

  const leftButtonContainer = {
    left: 35,
    flex: 1,
    height: screenStyles?.navigation_bar_button_height,

    padding: 5,
    position: "absolute",
    borderRadius: Number(screenStyles?.navigation_bar_button_radius),
    borderColor: screenStyles?.navigation_bar_button_border_color,
    borderWidth: screenStyles?.navigation_bar_button_border_size,
    backgroundColor: screenStyles?.navigation_bar_button_background_color,
  };
  
  const rightButtonContainer = {
    right: 35,
    flex: 1,
    height: screenStyles?.navigation_bar_button_height,

    padding: 5,
    position: "absolute",
    borderRadius: Number(screenStyles?.navigation_bar_button_radius),
    borderColor: screenStyles?.navigation_bar_button_border_color,
    borderWidth: screenStyles?.navigation_bar_button_border_size,
    backgroundColor: screenStyles?.navigation_bar_button_background_color,
  };
  const signInButtonContainer = {
    flex: 2,
    height: screenStyles?.sign_in_bar_button_height,

    padding: 5,
    position: "absolute",
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
        hidden={false}
      />
      <Button
        styles={signInButtonContainer}
        textStyle={TextStylSignInButtons}
        title={sign_in_button_text}
        onPress={onBack}
        disabled={isFistScreen}
        hidden={false}
      />
      <Button
        styles={rightButtonContainer}
        textStyle={TextStyleNavigationButtons}
        title={isLastScreen ? close_button_text : next_button_text}
        onPress={isLastScreen ? onClose : onNext}
        hidden={false}
        disabled={false}
      />
    </View>
  );
}
