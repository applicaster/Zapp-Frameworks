import React, { useRef, useMemo, useState } from "react";
import { View, ScrollView, Platform } from "react-native";
import PropTypes from "prop-types";
import * as R from "ramda";
import PrivacyTitle from "./PrivacyTitle";
import PrivacyDescription from "./PrivacyDescription";
import { useBackHandler, useDirectionalHandler } from "../../../../Utils/Hooks";
import { TVEventHandlerComponent } from "@applicaster/zapp-react-native-tvos-ui-components/Components/TVEventHandlerComponent";
import { Focusable } from "@applicaster/zapp-react-native-ui-components/Components/Focusable";

const scrollInterval = 50;

const PrivacyPolicyTv = (props) => {
  const [y, setY] = useState(0);
  const [yOffset, setyOffset] = useState(0);
  const [maxYOffset, setMaxYOffset] = useState(0);
  const [scrollViewHeight, setScrollViewHeight] = useState();
  const [scrollViewContentHeight, setScrollViewContentHeight] = useState();
  const scrollViewRef = useRef(null);

  const { screenStyles, onHandleBack, screenLocalizations } = props;
  const {
    privacy_screen_background_color,
    privacy_text_area_background_color,
  } = screenStyles;

  const privacy_text =
    screenLocalizations?.privacy_text || "Description - No data";
  const privacy_main_title_text =
    screenLocalizations?.privacy_main_title_text || "Title - No data";

  const hardwareBack = () => {
    onHandleBack();
  };

  const isAndroid = Platform.OS === "android";

  useBackHandler(hardwareBack);

  // Android Scrolling Handler
  const onUp = React.useCallback(() => {
    const newOffset = R.max(0, y - scrollInterval);
    scrollViewRef.current.scrollTo({ y: newOffset });
    setY(newOffset);
  }, [y, maxYOffset]);

  const onDown = React.useCallback(() => {
    const newOffset = R.min(maxYOffset, y + scrollInterval);

    scrollViewRef.current.scrollTo({ y: newOffset });
    setY(newOffset);
  }, [y, maxYOffset]);

  useDirectionalHandler({ onUp, onDown });

  // IOS Scrolling Handler

  const tvosRemoteHandler = (component, event) => {
    const { eventType } = event;
    if (eventType === "swipeDown" || eventType === "down") {
      if (y + yOffset + scrollViewHeight > scrollViewContentHeight) {
        setY(scrollViewContentHeight - scrollViewHeight);
        scrollViewRef.current.scrollTo({ y: scrollViewContentHeight });
      } else {
        scrollViewRef.current.scrollTo({ y: y + yOffset });
        setY(y + yOffset);
      }
    } else if (eventType === "swipeUp" || eventType === "up") {
      if (y - yOffset < 0) {
        setY(0);
        scrollViewRef.current.scrollTo({ y: 0 });
      } else {
        scrollViewRef.current.scrollTo({ y: y - yOffset });
        setY(y - yOffset);
      }
    }
  };

  const styles = useMemo(() => ({
    container: {
      flex: 1,
      width: "100%",
      alignContent: "center",
      backgroundColor: privacy_screen_background_color,
    },
    scrollViewWrapper: {
      flex: 1,
      marginTop: 75,
      marginLeft: 270,
      marginRight: 270,
      backgroundColor: privacy_text_area_background_color,
    },
    scrollView: {
      marginTop: 66,
      flex: 1,
    },
  }));

  const onLayout = ({ nativeEvent }) => {
    const { height } = nativeEvent?.layout;

    setMaxYOffset(nativeEvent?.target);
    setScrollViewHeight(height);
    const quaterOfTheScrollViewHeight = (height / 100) * 25;
    setyOffset(quaterOfTheScrollViewHeight);
  };

  function renderPolicy() {
    return (
      <View style={styles.scrollViewWrapper}>
        <PrivacyTitle title={privacy_main_title_text} {...props} />
        <ScrollView
          style={styles.scrollView}
          persistentScrollbar={true}
          contentInset={{ top: 0, left: 0, bottom: 100, right: 0 }}
          onContentSizeChange={(contentWidth, contentHeight) => {
            setScrollViewContentHeight(contentHeight + 100);
          }}
          onLayout={onLayout}
          ref={scrollViewRef}
        >
          <PrivacyDescription text={privacy_text} {...props} />
        </ScrollView>
      </View>
    );
  }
  function rootComponent() {
    if (isAndroid) {
      return <View style={styles.container}>{renderPolicy()}</View>;
    } else {
      return (
        <Focusable
          style={styles.container}
          isParallaxDisabled={true}
          isPressDisabled={true}
          id={"privacy-policy-tv"}
        >
          {renderPolicy()}
        </Focusable>
      );
    }
  }

  return (
    <TVEventHandlerComponent tvEventHandler={tvosRemoteHandler}>
      {rootComponent()}
    </TVEventHandlerComponent>
  );
};

PrivacyPolicyTv.propTypes = {
  screenStyles: PropTypes.object,
  screenLocalizations: PropTypes.object,
  onHandleBack: PropTypes.func,
};

PrivacyPolicyTv.defaultProps = {
  screenStyles: {},
  screenLocalizations: {},
  onHandleBack: R.identity,
};

export default PrivacyPolicyTv;