import * as R from "ramda";
import { OfferItem } from "../../models/Response";
import { isAndroidPlatform, isApplePlatform } from "../Platform";
export async function preparePayload({ payload, cleengResponse }) {
  let newPayload = payload;
  if (newPayload) {
    if (R.isNil(newPayload?.extensions)) {
      newPayload.extensions = {};
    }

    newPayload.extensions.in_app_purchase_data = {
      productsToPurchase: prepareInAppPurchaseData(cleengResponse),
    };
  }

  return newPayload;
}

export function prepareInAppPurchaseData(cleengResponse) {
  const result = R.map((item) => {
    const productType = "subscription";
    if (isApplePlatform) {
      return {
        ...item,
        productType,
        productIdentifier: item?.appleProductId,
      };
    } else if (isAndroidPlatform) {
      return {
        ...item,
        productType,
        productIdentifier: item?.androidProductId,
      };
    }
    return item;
  })(cleengResponse);
  return result;
}

export const isAuthenticationRequired = ({ payload }) => {
  const requires_authentication = R.path([
    "extensions",
    "requires_authentication",
  ])(payload);

  return requires_authentication;
};

export function getArraysIntersection(a1: Array<string>, a2: Array<string>) {
  if (!a1 || !a2 || a1.length === 0 || a2.length === 0) {
    return false;
  }
  const result = a1.filter(function (n) {
    return a2.indexOf(n) !== -1;
  });
  return result.length > 0 ? true : false;
}

export const getRiversProp = (key, rivers = {}) => {
  const getPropByKey = R.compose(
    R.prop(key),
    R.find(R.propEq("type", "zapp-cleeng-storefront")),
    R.values
  );

  return getPropByKey(rivers);
};
