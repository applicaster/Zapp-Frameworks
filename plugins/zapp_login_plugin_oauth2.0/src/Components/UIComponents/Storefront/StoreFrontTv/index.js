import React from "react";
import { StyleSheet, View } from "react-native";
import * as R from "ramda";
import PropTypes from "prop-types";

import SubscriptionTitle from "./SubscriptionTitle";
import SubscriptionDescription from "./SubscriptionDescription";
import EventDateTitle from "./EventDateTitle";
import PolicyAgreementTitle from "./PolicyAgreementTitle";
import FeesScrollView from "./FeesScrollView";
import ClientLogo from "../../ClientLogo";
import Button from "../../Buttons/FocusableButton";
import ButtonUnderline from "../../Buttons/FocusableButtonUnderline";
import { mapKeyToStyle } from "../../../../Utils/Customization";
import {
  useBackHandler,
  androidOnlySetInitialFocus,
} from "../../../../Utils/Hooks";

const StoreFrontTv = (props) => {
  const {
    screenStyles,
    screenLocalizations,
    onPressRestore,
    onPressPrivacyPolicy,
    onHandleBack,
  } = props;

  const {
    storefront_screen_background_color: screenBackground = null,
    client_logo: logoUrl = "",
    restore_purchase_action_button_background_color,
    restore_purchase_active_action_button_background_color,
    subscriber_agreement_and_privacy_policy_text_active_color,
  } = screenStyles;

  const {
    restore_purchase_action_button_text,
    subscriber_agreement_and_privacy_policy_text,
  } = screenLocalizations;

  const subscriptionsListRef = React.useRef(null);
  const restorePurchaseButtonRef = React.useRef(null);
  const agreementButtonRef = React.useRef(null);

  const hardwareBack = () => {
    onHandleBack();
  };

  useBackHandler(hardwareBack);

  androidOnlySetInitialFocus(subscriptionsListRef);

  const styles = React.useMemo(() =>
    StyleSheet.create({
      container: {
        flex: 1,
        width: "100%",
        alignContent: "center",
        backgroundColor: screenBackground,
      },
      contentWrapper: {
        marginTop: 150,
        marginLeft: 182,
        marginRight: 182,
      },
      clientLogoView: {
        position: "absolute",
        top: 58,
        left: 58,
      },
      restoreButtonWrapperView: {
        height: 88,
        width: 556,
        bottom: 140,
        position: "absolute",
        alignSelf: "center",
      },
      subscriberAgreementWrapperView: {
        bottom: 60,
        position: "absolute",
        alignSelf: "center",
        left: 177,
        right: 177,
      },
    })
  );
  const restoreButtonTextStyle = React.useMemo(
    () => mapKeyToStyle("restore_purchase_action_button_text", screenStyles),
    [screenStyles]
  );

  const subscriberAgreementStyles = React.useMemo(
    () =>
      mapKeyToStyle(
        "subscriber_agreement_and_privacy_policy_text",
        screenStyles
      ),
    [screenStyles]
  );

  return (
    <View style={styles.container}>
      <View style={styles.clientLogoView}>
        <ClientLogo imageSrc={logoUrl} />
      </View>
      <View style={styles.contentWrapper}>
        <SubscriptionTitle {...props} />
        <EventDateTitle {...props} />
        <SubscriptionDescription {...props} />
        <PolicyAgreementTitle {...props} />
      </View>
      <FeesScrollView
        ref={subscriptionsListRef}
        nextFocusDown={restorePurchaseButtonRef}
        {...props}
      />
      <View style={styles.restoreButtonWrapperView}>
        <Button
          ref={restorePurchaseButtonRef}
          nextFocusUp={subscriptionsListRef}
          nextFocusDown={agreementButtonRef}
          label={restore_purchase_action_button_text}
          textStyles={restoreButtonTextStyle}
          textColorFocused={restoreButtonTextStyle.color}
          onPress={onPressRestore}
          backgroundColor={restore_purchase_action_button_background_color}
          backgroundColorFocused={
            restore_purchase_active_action_button_background_color
          }
        />
      </View>
      <View style={styles.subscriberAgreementWrapperView}>
        <ButtonUnderline
          ref={agreementButtonRef}
          nextFocusUp={restorePurchaseButtonRef}
          textStyles={subscriberAgreementStyles}
          textColorFocused={
            subscriber_agreement_and_privacy_policy_text_active_color
          }
          containerStyle={styles.subscriberAgreementButton}
          containerStyleActive={styles.subscriberAgreementButtonActive}
          label={subscriber_agreement_and_privacy_policy_text}
          onPress={onPressPrivacyPolicy}
        />
      </View>
    </View>
  );
};

export default StoreFrontTv;

StoreFrontTv.propTypes = {
  screenStyles: PropTypes.object,
  onHandleBack: PropTypes.func,
  onPressRestore: PropTypes.func,
  onPressPrivacyPolicy: PropTypes.func,
  screenLocalizations: PropTypes.shape({
    restore_purchase_action_button_text: PropTypes.string,
    subscriber_agreement_and_privacy_policy_text: PropTypes.string,
  }),
};

StoreFrontTv.defaultProps = {
  screenStyles: {},
  onHandleBack: R.identity,
  onPressRestore: R.identity,
  onPressPrivacyPolicy: R.identity,
  screenLocalizations: {},
};
