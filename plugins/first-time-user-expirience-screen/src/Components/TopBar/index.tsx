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
  screenLocalizations,
  onBack,
  onNext,
  onClose,
}) {
  console.log({ screenLocalizations });
  const { back_button_text, next_button_text } = screenLocalizations;
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
      />
      <TopButton
        style={rightButtonContainer}
        textStyle={TextStyle}
        title={next_button_text}
      />
    </View>
  );
}
