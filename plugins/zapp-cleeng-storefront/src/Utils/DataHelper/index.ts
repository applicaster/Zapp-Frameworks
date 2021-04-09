import * as R from "ramda";
import { isAndroidPlatform, isApplePlatform } from "../Platform";
export async function preparePayload({
  payload,
  cleengResponse,
  purchasedItems,
}) {
  let newPayload = payload;
  if (newPayload) {
    if (R.isNil(newPayload?.extensions)) {
      newPayload.extensions = {};
    }
    newPayload.extensions.in_app_purchase_data = {
      productsToPurchase: prepareInAppPurchaseData(
        cleengResponse,
        purchasedItems
      ),
    };
  }

  return newPayload;
}

export function prepareInAppPurchaseData(cleengResponse, purchasedItems) {
  const result = R.map((item) => {
    const productType = "subscription";
    const authId = item?.authId;
    let purchased = false;
    if (authId && purchasedItems && purchasedItems.length > 0) {
      purchased = purchasedItems.find((item) => authId === item) ? true : false;
    }
    if (isApplePlatform) {
      return {
        ...item,
        productType,
        productIdentifier: item?.appleProductId,
        purchased,
      };
    } else if (isAndroidPlatform) {
      return {
        ...item,
        productType,
        productIdentifier: item?.androidProductId,
        purchased,
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

export function isItemsIntersected(
  a1: Array<string>,
  a2: Array<string>
): boolean {
  const result = getArraysIntersection(a1, a2);

  return result && result.length > 0 ? true : false;
}

export function getArraysIntersection(
  a1: Array<string>,
  a2: Array<string>
): Array<string> {
  if (!a1 || !a2 || a1.length === 0 || a2.length === 0) {
    return [];
  }
  const result = a1.filter(function (n) {
    return a2.indexOf(n) !== -1;
  });
  return result;
}

export const getRiversProp = (key, rivers = {}) => {
  const getPropByKey = R.compose(
    R.prop(key),
    R.find(R.propEq("type", "zapp-cleeng-storefront")),
    R.values
  );

  return getPropByKey(rivers);
};
