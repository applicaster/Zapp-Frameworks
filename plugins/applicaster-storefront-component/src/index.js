import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";
import StoreFrontMobile from "./StoreFrontMobile";
import StoreFrontTv from "./StoreFrontTv";
import React, { useState, useLayoutEffect } from "react";
import PropTypes from "prop-types";
import LoadingScreen from "./LoadingScreen";
import PrivacyPolicy from "./PrivacyPolicy";
import MESSAGES from "./Config";
import { showAlert } from "./Helper";
import { useToggleNavBar } from "./Utils/Hooks";
import { isApplePlatform } from "./Utils/Platform";
import ParentLockPlugin from "@applicaster/quick-brick-parent-lock";

import {
  purchaseAnItem,
  retrieveProducts,
  restore,
  initialize,
  setDebugEnabled,
} from "./Services/iAPService";

import { createLogger } from "./Services/LoggerService";
import * as R from "ramda";
export const logger = createLogger({
  subsystem: "Storefront",
});
import { useSelector } from "react-redux";

export default function Storefront(props) {
  let showParentLock =
    (props?.screenStyles?.import_parent_lock === "1" ||
      props?.screenStyles?.import_parent_lock === true) &&
    props?.payload?.extensions?.skip_parent_lock !== true
      ? true
      : false;
  const isDebugModeEnabled = props?.isDebugModeEnabled === true;

  useToggleNavBar();

  const ScreensData = {
    EMPTY: "Empty",
    STOREFRONT: "Storefront",
    PRIVACY_POLICY: "PrivacyPolicy",
    PARENT_LOCK: "ParentLock",
  };

  const [screen, setScreen] = useState(ScreensData.EMPTY);
  const [dataSource, setDataSource] = useState(null);
  const [iapInitialized, setIapInitialized] = useState(!isAndroid);
  const [loading, setLoading] = useState(true);
  const isAndroid = Platform.OS === "android";
  const { store } = useSelector(R.prop("appData"));

  useLayoutEffect(() => {
    prepareStoreFront();
  }, []);

  async function initializeIap() {
    try {
      // Enables stubs for iap
      setDebugEnabled(isDebugModeEnabled);

      logger.debug({
        message: "initializeIap: Initializing IAP plugin`",
      });

      const result = await initialize(store);
      if (result) {
        setIapInitialized(true);
      }
    } catch (error) {
      logger.error({
        message: `initializeIap: Initializing IAP plugin, FAILED: ${error}`,
        data: { error },
      });
      onStorefrontCompleted({ success: false });
    }
  }

  const presentParentLock = () => {
    setScreen(ScreensData.PARENT_LOCK);
  };

  const parentLockCallback = (result) => {
    if (result.success) {
      setScreen(ScreensData.STOREFRONT);
    } else {
      onStorefrontCompleted({ success: false });
    }
  };

  async function prepareStoreFront() {
    await initializeIap();
    await preparePurchaseData();
  }
  function syncPurchaseData({ productsToPurchase, storeFeesData }) {
    let retVal = [];
    for (let i = 0; i < storeFeesData.length; i++) {
      const storeFee = storeFeesData[i];
      for (let i = 0; i < productsToPurchase.length; i++) {
        const productToPurchase = productsToPurchase[i];
        console.log({ productToPurchase });
        if (
          productToPurchase.productIdentifier === storeFee.productIdentifier
        ) {
          storeFee.productType = productToPurchase.productType;
          storeFee.purchased = productToPurchase.purchased;
          storeFee.expiresAt = productToPurchase.expiresAt;

          if (!storeFee.title && productToPurchase.title) {
            storeFee.title = productToPurchase.title;
          }
          retVal.push(storeFee);
          break;
        }
      }
    }
    return retVal;
  }
  async function preparePurchaseData() {
    try {
      const productsToPurchase =
        props?.payload?.extensions?.in_app_purchase_data?.productsToPurchase;
      const storeFeesData = await retrieveProducts(productsToPurchase);
      if (storeFeesData.length === 0) {
        throw new Error(MESSAGES.validation.emptyStore);
      }

      const mappedFeeData = syncPurchaseData({
        storeFeesData,
        productsToPurchase,
      });
      const parentLockWasPresented =
        props?.payload.extensions?.parentLockWasPresented;

      if (showParentLock && !parentLockWasPresented) {
        presentParentLock();
      } else {
        setScreen(ScreensData.STOREFRONT);
      }
      setLoading(false);
      setDataSource(mappedFeeData);
    } catch (error) {
      setLoading(false);
      onStorefrontCompleted({ success: false, error });
    }
  }

  const buyItem = async ({ productIdentifier, productType }) => {
    if (!productIdentifier || !productType) {
      const error = new Error(MESSAGES.validation.productId);
      onStorefrontCompleted({ success: false, error });
    }
    try {
      const result = await purchaseAnItem({
        productIdentifier,
        productType,
      });
      setDataSource(null);
      setLoading(false);
      let newPayload = props?.payload;
      newPayload.extensions.in_app_purchase_data.purchasedProduct = result;
      onStorefrontCompleted({
        success: true,
        error: null,
        payload: newPayload,
      });
    } catch (error) {
      setLoading(false);

      const alertTitle = MESSAGES.purchase.fail;
      showAlert(alertTitle, error.message);
      isApplePlatform && hideLoader();
    }
  };
  const hideLoader = () => {
    setLoading(false);
  };

  const onPressPaymentOption = (index) => {
    isApplePlatform && setLoading(true);

    const itemToPurchase = dataSource[index];
    return buyItem(itemToPurchase);
  };

  const onRestoreSuccess = () => {
    setLoading(false);
  };

  const onPressPrivacyPolicy = () => {
    setScreen(ScreensData.PRIVACY_POLICY);
  };

  async function onPressRestore() {
    setLoading(true);

    restore()
      .then(async (data) => {
        const onRestoreCompleted = props?.onRestoreCompleted;

        await onRestoreCompleted(data);
        onRestoreSuccess();
      })
      .catch((err) => {
        throw err;
      });
  }

  const onHandleBack = () => {
    if (screen === ScreensData.PRIVACY_POLICY) {
      setScreen(ScreensData.STOREFRONT);
    } else if (screen === ScreensData.STOREFRONT) {
      onStorefrontCompleted({ success: false });
    }
  };

  function onStorefrontCompleted({ success, error, payload }) {
    props?.onStorefrontFinished?.({ success, error, payload });
  }
  const mobile = (
    <StoreFrontMobile
      {...props}
      onHandleBack={onHandleBack}
      dataSource={dataSource}
      onPressPaymentOption={onPressPaymentOption}
      onPressRestore={onPressRestore}
      onPressPrivacyPolicy={onPressPrivacyPolicy}
    />
  );
  const tv = (
    <StoreFrontTv
      {...props}
      onHandleBack={onHandleBack}
      dataSource={dataSource}
      onPressPaymentOption={onPressPaymentOption}
      onPressRestore={onPressRestore}
      onPressPrivacyPolicy={onPressPrivacyPolicy}
    />
  );
  function renderStoreFront() {
    return platformSelect({
      tvos: tv,
      ios: mobile,
      android: mobile,
      web: tv,
      android_tv: tv,
      samsung_tv: tv,
      lg_tv: tv,
    });
  }

  const render = () => {
    if (!dataSource || loading || !iapInitialized) {
      return <LoadingScreen />;
    }
    switch (screen) {
      case ScreensData.PARENT_LOCK:
        return <ParentLockPlugin.Component callback={parentLockCallback} />;
      case ScreensData.STOREFRONT:
        return renderStoreFront();
      case ScreensData.PRIVACY_POLICY:
        return <PrivacyPolicy {...props} onHandleBack={onHandleBack} />;
    }
  };

  return render();
}
