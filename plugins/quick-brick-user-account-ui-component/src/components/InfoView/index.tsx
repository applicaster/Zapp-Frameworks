import * as React from "react";
import { View, TouchableHighlight, Text, StyleSheet } from "react-native";
import { handleStyleType } from "../../utils";
import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";

type Props = {
  titles: {
    titleText: string;
    descriptionText: string;
  };
  styles: {
    titleStyle: {
      title_color: string;
      title_text_fontsize: string;
      title_text_font_ios: string;
      title_text_font_android: string;
    };
    description_style: {
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
  },
  flexOne: {
    flex: 1,
    justifyContent: "center",
  },
  labelStyles: {
    textAlign: "left",
    justifyContent: "center",
  },
});

export function InfoView(props: Props) {
  const propsTitleStyle = props?.styles?.titleStyle;
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
    <View>
      <View style={componentStyles.containerStyle}>
        <Text numberOfLines={1} style={titleLabelStyle}>
          {props?.titles?.titleText}
        </Text>
      </View>
      <View style={componentStyles.containerStyle}>
        <Text numberOfLines={1} style={descriptionLabelStyle}>
          {props?.titles?.descriptionText}
        </Text>
      </View>
    </View>
  );
}
