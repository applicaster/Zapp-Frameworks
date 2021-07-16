import * as React from "react";
import { View, TouchableHighlight, Text, StyleSheet } from "react-native";
import { handleStyleType } from "../../utils";
import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";

type Props = {
  id: string;
  onPress: () => void;
  text: string;
  styles: {
    containerStyle: {
      background_underlay_color: string;
      background_color: string;
      button_radius: string;
    };
    textStyles: {
      title_underlay_color: string;
      title_color: string;
      title_text_fontsize: string;
      title_text_font_ios: string;
      title_text_font_android: string;
    };
  };
};

const componentStyles = StyleSheet.create({
  containerStyle: {
    flex: 1,
    flexDirection: "row",
    borderRadius: 5,
  },
  flexOne: {
    flex: 1,
    justifyContent: "center",
  },
  textStyles: {
    textAlign: "center",
    justifyContent: "center",
  },
});

function Button(props) {
  const [isUnderlay, setIsUnderlay] = React.useState(false);

  function onShowUnderlay() {
    setIsUnderlay(true);
  }

  function onHideUnderlay() {
    setIsUnderlay(false);
  }

  const propsContainerStyle = props?.styles?.containerStyle;
  const propsTextStyle = props?.styles?.textStyle;

  const containerStyle = {
    ...componentStyles.containerStyle,
    backgroundColor: propsContainerStyle?.background_color,
    borderRadius: Number(propsContainerStyle?.button_radius),
  };
  const background_underlay_color =
    propsContainerStyle?.background_underlay_color;

  const textStyle = {
    ...componentStyles.textStyles,
    color: isUnderlay
      ? propsTextStyle?.title_underlay_color
      : propsTextStyle?.title_color,
    fontSize: handleStyleType(propsTextStyle?.title_text_fontsize),
    fontFamily: platformSelect({
      ios: propsTextStyle?.title_text_font_ios,
      android: propsTextStyle?.title_text_font_android,
    }),
  };

  return (
    <TouchableHighlight
      onPress={props?.onPress}
      testID={`${props?.id}`}
      style={containerStyle}
      onHideUnderlay={onHideUnderlay}
      onShowUnderlay={onShowUnderlay}
      underlayColor={background_underlay_color}
      accessible={false}
    >
      <View style={componentStyles.flexOne}>
        <Text numberOfLines={2} style={textStyle}>
          {props?.text}
        </Text>
      </View>
    </TouchableHighlight>
  );
}
