import React, { useState, useEffect, useCallback, useMemo } from "react";
import { Platform, View } from "react-native";
import TopButton from "../Buttons/TopButton";
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

const leftButtonContainer = {
  left: 35,
  position: "absolute",
};
const rightButtonContainer = {
  right: 35,
  position: "absolute",
};

export default function TopBar({
  screenStyles,
  localizations,
  onBack,
  onNext,
  onClose,
  onSkip,
}) {
  console.log({ localizations });
  const { back_button_text, next_button_text } = localizations;
  const TextStyle = {
    fontFamily: platformSelect({
      ios: screenStyles?.back_button_font_ios,
      android: screenStyles?.back_button_font_android,
    }),
    fontSize: screenStyles?.back_button_font_size,
    color: screenStyles?.back_button_font_color,
  };

  return (
    <View
      style={{
        backgroundColor: "gray",
        height: 64,
        justifyContent: "center",
      }}
    >
      <TopButton
        style={leftButtonContainer}
        textStyle={TextStyle}
        title={back_button_text}
      ></TopButton>
      <TopButton
        style={rightButtonContainer}
        textStyle={TextStyle}
        title={next_button_text}
      ></TopButton>
    </View>
  );
}
