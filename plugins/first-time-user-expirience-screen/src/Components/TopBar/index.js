import React from "react";
import { View } from "react-native";
import Button from "../Buttons/Button";
import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useDimensions } from "@applicaster/zapp-react-native-utils/reactHooks";
import { useSafeAreaFrame } from "react-native-safe-area-context";
export default function TopBar({
  screenStyles,
  screenLocalizations,
  onBack,
  onNext,
  onClose,
  onSignUp,
  isLastScreen = false,
  isFistScreen = false,
}) {
  const insets = useSafeAreaInsets();
  const dimensions = useSafeAreaFrame();

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

  const TextStyleNavigationButtonsDisabled = {
    ...TextStyleNavigationButtons,
    color: screenStyles?.navigation_bar_button_font_color_disabled,
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

  const TextStylSignInButtonsDisabled = {
    ...TextStyleNavigationButtons,
    color: screenStyles?.sign_in_bar_button_font_color_disabled,
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

  const buttonContainerStyle = {
    backgroundColor: screenStyles?.bottom_bar_background_color,
    height: insets.bottom,
    position: "absolute",
    bottom: 0,
    width: dimensions.width,
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
  const leftButtonContainerDisabled = {
    ...leftButtonContainer,
    backgroundColor:
      screenStyles?.navigation_bar_button_background_color_disabled,
    borderColor: screenStyles?.navigation_bar_button_border_color_disabled,
  };
  const rightButtonContainer = {
    flex: 1,
    height: screenStyles?.navigation_bar_button_height,
    justifyContent: "center",
    alignItems: "center",
    borderRadius: Number(screenStyles?.navigation_bar_button_radius),
    borderColor: screenStyles?.navigation_bar_button_border_color,
    borderWidth: screenStyles?.navigation_bar_button_border_size,
    backgroundColor: screenStyles?.navigation_bar_button_background_color,
  };

  const rightButtonContainerDisabled = {
    ...rightButtonContainer,
    backgroundColor:
      screenStyles?.navigation_bar_button_background_color_disabled,
    borderColor: screenStyles?.navigation_bar_button_border_color_disabled,
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

  const signInButtonContainerDisabled = {
    ...signInButtonContainer,
    backgroundColor: screenStyles?.sign_in_bar_button_background_color_disabled,
    borderColor: screenStyles?.sign_in_bar_button_border_color_disabled,
  };

  return (
    <>
      <View style={ContainerStyle}>
        <Button
          styles={leftButtonContainer}
          stylesDisabled={leftButtonContainerDisabled}
          textStyle={TextStyleNavigationButtons}
          textStyleDisabled={TextStyleNavigationButtonsDisabled}
          title={back_button_text}
          onPress={onBack}
          disabled={isFistScreen}
          hidden={screenStyles?.is_bar_back_button_hidden === "1"}
        />
        <Button
          styles={signInButtonContainer}
          stylesDisabled={signInButtonContainerDisabled}
          textStyle={TextStylSignInButtons}
          textStyleDisabled={TextStylSignInButtonsDisabled}
          title={sign_in_button_text}
          onPress={onSignUp}
          disabled={isFistScreen && isLastScreen === false}
          hidden={screenStyles?.is_bar_login_button_hidden === "1"}
        />
        <Button
          styles={rightButtonContainer}
          stylesDisabled={rightButtonContainerDisabled}
          textStyle={TextStyleNavigationButtons}
          textStyleDisabled={TextStyleNavigationButtonsDisabled}
          title={isLastScreen ? close_button_text : next_button_text}
          onPress={isLastScreen ? onClose : onNext}
          disabled={false}
          hidden={screenStyles?.is_bar_next_button_hidden === "1"}
        />
      </View>
      <View style={buttonContainerStyle} />
    </>
  );
}
