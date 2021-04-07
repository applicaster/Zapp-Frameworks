import * as R from "ramda";
import { OfferItem } from "../../models/Response";
import { isAndroidPlatform, isApplePlatform } from "../Platform";
export async function preparePayload({ payload, cleengResponse }) {
  let newPayload = payload;
  //   newPayload.extensions.cleeng_data = cleengResponse;
  newPayload.extensions.in_app_purchase_data = {
    productsToPurchase: prepareInAppPurchaseData(cleengResponse),
  };
  return newPayload;
}

export function prepareInAppPurchaseData(cleengResponse) {
  console.log({ cleengResponse });
  const result = R.map((item) => {
    console.log({ item });
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
    console.log({ item });
    return item;
  })(cleengResponse);
  console.log({ result });
  return result;
}

export const isAuthenticationRequired = ({ payload }) => {
  const requires_authentication = R.path([
    "extensions",
    "requires_authentication",
  ])(payload);

  // logger.debug({
  //   message: `Payload entry is requires_authentication: ${requires_authentication}`,
  //   data: {
  //     requires_authentication: requires_authentication,
  //   },
  // });
  return requires_authentication;
};

export function getArraysIntersection(a1: Array<string>, a2: Array<string>) {
  if (!a1 || !a2 || a1.length === 0 || a2.length === 0) {
    return false;
  }
  const result = a1.filter(function (n) {
    return a2.indexOf(n) !== -1;
  });
  console.log({ result });
  return result.length > 0 ? true : false;
}
