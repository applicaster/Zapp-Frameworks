import * as React from "react";
import { View, TouchableHighlight, Text, StyleSheet } from "react-native";
import { handleStyleType } from "../../utils";
import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";

type Props = {
  id: string;
  onPress: () => void;
  titleText: string;
  styles: {
    containerStyle: {
      background_underlay_color: string;
      background_color: string;
      button_radius: string;
    };
    labelStyles: {
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
  labelStyles: {
    textAlign: "center",
    justifyContent: "center",
  },
});

export function Button(props: Props) {
  const [isUnderlay, setIsUnderlay] = React.useState(false);

  function onShowUnderlay() {
    setIsUnderlay(true);
  }

  function onHideUnderlay() {
    setIsUnderlay(false);
  }

  const propsContainerStyle = props?.styles?.containerStyle;
  const propsLabelStyles = props?.styles?.labelStyles;

  const containerStyle = {
    ...componentStyles.containerStyle,
    backgroundColor: propsContainerStyle?.background_color,
    borderRadius: Number(propsContainerStyle?.button_radius),
  };
  const background_underlay_color =
    propsContainerStyle?.background_underlay_color;

  const labelStyles = {
    ...componentStyles.labelStyles,
    color: isUnderlay
      ? propsLabelStyles?.title_underlay_color
      : propsLabelStyles?.title_color,
    fontSize: handleStyleType(propsLabelStyles?.title_text_fontsize),
    fontFamily: platformSelect({
      ios: propsLabelStyles?.title_text_font_ios,
      android: propsLabelStyles?.title_text_font_android,
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
        <Text numberOfLines={2} style={labelStyles}>
          {props?.titleText}
        </Text>
      </View>
    </TouchableHighlight>
  );
}
