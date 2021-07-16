import * as React from "react";
import { View, StyleSheet } from "react-native";
import { InfoView } from "../InfoView";
import { Button } from "../Button";

type Props = {
  onLogoutPress: () => void;
  titles: {
    account_title: string;
    user_name_title: string;
    subscription_title: string;
    subscription_expiration_title: string;
    logout_title_text: string;
  };
  styles: {
    logoutButtonStyles: {
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
    accountDataStyle: {
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
    subscriptionDataStyle: {
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
};

const componentStyles = StyleSheet.create({
  flexOne: {
    flex: 1,
    justifyContent: "flex-start",
  },
});

export function AccountInfo(props: Props) {
  const titles = props?.titles;

  const logoutButtonStyles = props?.styles?.logoutButtonStyles;

  const accountDataStyles = props?.styles?.accountDataStyle;
  const accountDataTitles = {
    titleText: titles.account_title,
    descriptionText: titles.user_name_title,
  };

  const subscriptionDataStyles = props?.styles?.subscriptionDataStyle;
  const subscriptionDataTitles = {
    titleText: titles.subscription_title,
    descriptionText: titles.subscription_expiration_title,
  };
  return (
    <View style={componentStyles.flexOne}>
      <InfoView styles={accountDataStyles} titles={accountDataTitles} />
      <InfoView
        styles={subscriptionDataStyles}
        titles={subscriptionDataTitles}
      />
      <Button
        onPress={props?.onLogoutPress}
        titleText={titles.logout_title_text}
        styles={logoutButtonStyles}
        id={"logout"}
      />
    </View>
  );
}
