import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";
import StoreFrontMobile from "./StoreFrontMobile";
import StoreFrontTv from "./StoreFrontTv";
import React, { useState, useLayoutEffect } from "react";
import PropTypes from "prop-types";
import LoadingScreen from "../LoadingScreen";
import PrivacyPolicy from "./PrivacyPolicy";
import MESSAGES from "./Config";
import { showAlert } from "./Helper";
import { useToggleNavBar } from "../../Utils/Hooks";
import { addInPlayerProductId } from "../AssetFlow/Helper";
import {
  purchaseAnItem,
  retrieveProducts,
  restore,
  initialize,
} from "./Services/iAPService";
import {
  createLogger,
  Subsystems,
  XRayLogLevel,
} from "../../Services/LoggerService";
import * as R from "ramda";
export const logger = createLogger({
  subsystem: "Storefront",
});
import { useSelector } from "react-redux";

export default function Storefront(props) {
  useToggleNavBar();

  const ScreensData = {
    EMPTY: "Empty",
    STOREFRONT: "Storefront",
    PRIVACY_POLICY: "PrivacyPolicy",
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

  async function prepareStoreFront() {
    await initializeIap();
    await preparePurchaseData();
  }

  async function preparePurchaseData() {
    try {
      const productsToPurchase =
        props?.payload?.extensions?.in_app_purchase_data?.productsToPurchase;
      console.log({ productsToPurchase, props });

      const storeFeesData = await retrieveProducts(productsToPurchase);

      if (storeFeesData.length === 0) {
        throw new Error(MESSAGES.validation.emptyStore);
      }

      //TODO: Title should take from products to purchase if title not exist in products
      // const mappedFeeData = addInPlayerProductId({
      //   storeFeesData,
      //   inPlayerFeesData: productsToPurchase,
      // });
      console.log({ storeFeesData, productsToPurchase });
      setScreen(ScreensData.STOREFRONT);
      setLoading(false);
      setDataSource(storeFeesData);
    } catch (error) {
      setLoading(false);

      onStorefrontCompleted({ success: false, error });
    }
  }

  console.log("Storefront", { props });

  const buyItem = async ({
    productIdentifier,
    inPlayerProductId,
    productType,
  }) => {
    if (!productIdentifier || !inPlayerProductId) {
      const error = new Error(MESSAGES.validation.productId);
      onStorefrontCompleted({ success: false, error });
    }

    try {
      await purchaseAnItem({
        productIdentifier,
        productType,
      });

      setDataSource(null);
      setLoading(false);
      // return loadAsset({ startPurchaseFlow: false });
    } catch (error) {
      setLoading(false);

      const alertTitle = MESSAGES.purchase.fail;
      showAlert(alertTitle, error.message);
      isApplePlatform && hideLoader();
    }
  };

  const onPressPaymentOption = (index) => {
    isApplePlatform && setLoading(true);

    const itemToPurchase = dataSource[index];
    return buyItem(itemToPurchase);
  };

  const onRestoreSuccess = () => {
    setDataSource(null);
    setLoading(false);
  };

  const onPressPrivacyPolicy = () => {
    setScreen(ScreensData.PRIVACY_POLICY);
  };

  const onPressRestore = () => {
    setLoading(true);

    restore(dataSource)
      .then(() => {
        const alertTitle = MESSAGES.restore.success;
        const alertMessage = MESSAGES.restore.successInfo;
        showAlert(alertTitle, alertMessage, onRestoreSuccess);
      })
      .catch((err) => {
        const alertTitle = MESSAGES.restore.fail;
        showAlert(alertTitle, err.message, hideLoader);
      });
  };

  const onHandleBack = () => {
    if (screen === ScreensData.PRIVACY_POLICY) {
      setScreen(ScreensData.STOREFRONT);
    } else if (screen === ScreensData.STOREFRONT) {
      onStorefrontCompleted({ success: false });
    }
  };

  function onStorefrontCompleted({ success, error, payload }) {
    console.log("onStorefrontCompleted", { success, error, payload });
    props?.completeStorefrontFlow?.({ success, error, payload });
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
      case ScreensData.STOREFRONT:
        return renderStoreFront();
      case ScreensData.PRIVACY_POLICY:
        return <PrivacyPolicy {...props} onHandleBack={onHandleBack} />;
    }
  };

  return render();
}
