import * as React from "react";
import { View, TouchableHighlight, Text, StyleSheet } from "react-native";
import { handleStyleType } from "../../utils";
import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";

type Props = {
  titles: {
    title_text: string;
    description_text: string;
  };
  styles: {
    title_style: LabelStyles;
    description_style: LabelStyles;
  };
};

const componentStyles = StyleSheet.create({
  containerStyle: {
    flex: 1,
    paddingBottom: 20,
  },
  flexOne: {
    flex: 1,
    justifyContent: "center",
    paddingBottom: 5,
  },
  labelStyles: {
    textAlign: "left",
    justifyContent: "center",
  },
});

export function InfoView(props: Props) {
  const propsTitleStyle = props?.styles?.title_style;
  const propsDiscription = props?.styles?.description_style;

  const titleLabelStyle = {
    ...componentStyles.labelStyles,
    color: propsTitleStyle?.title_color,
    fontSize: handleStyleType(propsTitleStyle?.title_text_fontsize),
    fontFamily: platformSelect({
      ios: propsTitleStyle?.title_text_font_ios,
      android: propsTitleStyle?.title_text_font_android,
    }),
  };

  const descriptionLabelStyle = {
    ...componentStyles.labelStyles,
    color: propsDiscription?.title_color,
    fontSize: handleStyleType(propsDiscription?.title_text_fontsize),
    fontFamily: platformSelect({
      ios: propsDiscription?.title_text_font_ios,
      android: propsDiscription?.title_text_font_android,
    }),
  };
  return (
    <View style={componentStyles.containerStyle}>
      <View style={componentStyles.flexOne}>
        <Text numberOfLines={1} style={titleLabelStyle}>
          {props?.titles?.title_text}
        </Text>
      </View>
      <View style={componentStyles.flexOne}>
        <Text numberOfLines={1} style={descriptionLabelStyle}>
          {props?.titles?.description_text}
        </Text>
      </View>
    </View>
  );
}
