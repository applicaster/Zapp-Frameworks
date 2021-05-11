import React from "react";
import { Text, TouchableOpacity } from "react-native";
import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import ButtonImage from "../ButtonImage";
const FloatingButton = ({
  screenStyles,
  screenLocalizations,
  onNext,
  onClose,
  isLastScreen = false,
}) => {
  const hidden = screenStyles?.is_top_button_hidden === "1";
  const {
    back_button_text,
    next_button_text,
    close_button_text,
  } = screenLocalizations;
  const insets = useSafeAreaInsets();

  const textStyle = {
    fontFamily: platformSelect({
      ios: screenStyles?.top_button_font_ios,
      android: screenStyles?.top_button_font_android,
    }),
    fontSize: screenStyles?.top_button_font_size,
    color: screenStyles?.top_button_font_color,
  };
  const buttonStyleText = {
    right: insets.right + 10,
    top: insets.top + 10,
    padding: 5,
    position: "absolute",
    borderRadius: Number(screenStyles?.top_button_radius),
    borderColor: screenStyles?.top_button_border_color,
    borderWidth: screenStyles?.top_button_border_size,
    backgroundColor: screenStyles?.top_button_background_color,
  };

  const buttonStyleImage = {
    right: insets.right + 10,
    top: insets.top + 10,
    padding: 0,
    position: "absolute",
  };

  function renderButton() {
    if (screenStyles?.top_button_type === "image") {
      return renderImage();
    } else {
      return renderText();
    }
  }

  function renderImage() {
    const top_button_image_next = screenStyles?.top_button_image_next;
    const top_button_image_close = screenStyles?.top_button_image_close;
    return (
      <ButtonImage
        imageSrc={isLastScreen ? top_button_image_close : top_button_image_next}
      />
    );
  }

  function renderText() {
    return (
      <Text style={textStyle}>
        {isLastScreen ? close_button_text : next_button_text}
      </Text>
    );
  }
  return hidden === true ? null : (
    <TouchableOpacity
      style={
        screenStyles?.top_button_type === "image"
          ? buttonStyleImage
          : buttonStyleText
      }
      onPress={isLastScreen ? onClose : onNext}
    >
      {renderButton()}
    </TouchableOpacity>
  );
};

export default FloatingButton;