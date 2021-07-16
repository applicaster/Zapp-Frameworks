import * as React from "react";
import { View, StyleSheet } from "react-native";
import { InfoView } from "../InfoView";
import { Button } from "../Button";
import { UserPhoto } from "../UserPhoto";

type Props = {
  onLogoutPress: () => void;
  user_image_placeholder: string;
  titles: {
    account_title: string;
    user_name_title: string;
    subscription_title: string;
    subscription_expiration_title: string;
    logout_title_text: string;
  };
  styles: {
    logoutButtonStyles: ButtonStyles;
    labelStyles: {
      title_style: LabelStyles;
      description_style: LabelStyles;
    };
  };
};

const componentStyles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
    flexDirection: "row",
    paddingBottom: 20,
  },
  infoViewsContainer: {
    flex: 1,
    paddingLeft: 17,
    paddingTop: 35,
  },
});

export function AccountInfo(props: Props) {
  const titles = props?.titles;

  const logoutButtonStyles = props?.styles?.logoutButtonStyles;

  const labelStyles = props?.styles?.labelStyles;
  const accountDataTitles = {
    title_text: titles.account_title,
    description_text: titles.user_name_title,
  };

  const subscriptionDataTitles = {
    title_text: titles.subscription_title,
    description_text: titles.subscription_expiration_title,
  };
  return (
    <View style={componentStyles.container}>
      <UserPhoto imageSrc={props?.user_image_placeholder} />
      <View style={componentStyles.infoViewsContainer}>
        <InfoView styles={labelStyles} titles={accountDataTitles} />
        <InfoView styles={labelStyles} titles={subscriptionDataTitles} />
        <Button
          customContainerStyle={{
            height: 22,
            width: 99,
          }}
          onPress={props?.onLogoutPress}
          titleText={titles.logout_title_text}
          styles={logoutButtonStyles}
          id={"logout"}
        />
      </View>
    </View>
  );
}
