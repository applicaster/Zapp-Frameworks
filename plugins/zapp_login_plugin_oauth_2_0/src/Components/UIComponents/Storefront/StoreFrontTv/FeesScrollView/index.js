import React from "react";
import { StyleSheet, ScrollView, Platform, View } from "react-native";
import { FocusableGroup } from "@applicaster/zapp-react-native-ui-components/Components/FocusableGroup";
import { Focusable as AndroidFocusable } from "@applicaster/zapp-react-native-ui-components/Components/Focusable";

import { useFocusManager } from "@applicaster/zapp-react-native-utils/focusManager";

import FeeCard from "./FeeCard";
import PropTypes from "prop-types";

const isAndroid = Platform.OS === "android";

const styles = StyleSheet.create({
  container: {
    top: 500,
    left: 177,

    right: 177,
    height: 260,
    position: "absolute",
  },
  scrollViewContent: { flexGrow: 1, justifyContent: "center" },
});

const Focusable = isAndroid
  ? AndroidFocusable
  : ({ children }) => children(false, {});

const FocusableGroupWrapper = isAndroid ? View : FocusableGroup;
const FeesScrollView = React.forwardRef((props, ref) => {
  const { screenStyles, screenLocalizations, dataSource, onPressPaymentOption } = props;
  const [elRefs, setElRefs] = React.useState([]);
  const { isFocused, setFocus } = useFocusManager() || {};
  const isScrollViewFocused = isFocused?.("fees-scroll-view");
  const scrollRef = (isAndroid && React.createRef()) || null;

  const dataSourceLength = dataSource.length;

  React.useEffect(() => {
    setElRefs((elRefs) =>
      Array(dataSourceLength)
        .fill()
        .map((_, i) => elRefs[i] || React.createRef())
    );
  }, [dataSourceLength]);

  React.useLayoutEffect(() => {
    if (isScrollViewFocused) {
      setFocus(elRefs[0]);
    }
  }, [isScrollViewFocused, elRefs]);

  const scrollToFocusedItem = ({ x, y }) => {
    isAndroid && scrollRef.current.scrollTo({ x, y, animated: true });
  };

  const groupId = "fee-scroll-view";
  return (
    <FocusableGroupWrapper
      style={styles.container}
      id={groupId}
      shouldUsePreferredFocus
      isParallaxDisabled
    >
      <Focusable
        ref={isAndroid ? ref : null}
        id="fees-scroll-view"
        nextFocusDown={props.nextFocusDown}
        nextFocusUp={props.nextFocusUp}
      >
        {(focused, parentFocus) => (
          <ScrollView
            horizontal={true}
            contentContainerStyle={styles.scrollViewContent}
            ref={scrollRef}
          >
            {dataSource.map((item, index) => (
              <FeeCard
                ref={elRefs[index]}
                nextFocusUp={parentFocus.nextFocusUp}
                nextFocusDown={parentFocus.nextFocusDown}
                nextFocusRight={elRefs?.[index + 1]}
                nextFocusLeft={elRefs?.[index - 1]}
                groupId={groupId}
                onFocus={scrollToFocusedItem}
                screenStyles={screenStyles}
                screenLocalizations={screenLocalizations}
                paymentOptionItem={item}
                key={item.productIdentifier}
                identifier={item.productIdentifier}
                onPress={() => onPressPaymentOption(index)}
              />
            ))}
          </ScrollView>
        )}
      </Focusable>
    </FocusableGroupWrapper>
  );
});

FeesScrollView.propTypes = {
  screenStyles: PropTypes.object,
  screenLocalizations: PropTypes.object,
  payload: PropTypes.object,
  dataSource: PropTypes.array,
  onPressPaymentOption: PropTypes.func,
  nextFocusUp: PropTypes.object,
  nextFocusDown: PropTypes.object,
  focused: PropTypes.bool,
};

FeesScrollView.defaultProps = {
  payload: {},
  screenStyles: {},
  screenLocalizations: {},
  dataSource: [],
  onPressPaymentOption: () => {},
};

FeesScrollView.displayName = "FeesScrollView";

export default FeesScrollView;
