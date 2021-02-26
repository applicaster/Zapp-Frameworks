import { Platform } from "react-native";
import { isAmazonPlatform, isApplePlatform } from "../../Utils/Platform";
import * as R from "ramda";

export function externalIdProviderId({ in_player_environment, store }) {
  if (isApplePlatform) {
    if (in_player_environment == "production") {
      return 13;
    } else if (in_player_environment == "development") {
      return 12;
    }
  } else if (Platform.OS === "android") {
    if (isAmazonPlatform(store)) {
      return 17;
    } else {
      if (in_player_environment == "production") {
        return 15;
      } else if (in_player_environment == "development") {
        return 14;
      }
    }
  }
  return null;
}

export function externalIdForPlatform({ fee, in_player_environment, store }) {
  const { external_fees } = fee;
  const externalProviderID = externalIdProviderId({
    in_player_environment,
    store,
  });
  if (!external_fees || externalProviderID === null) {
    return null;
  }
  const retVal = R.compose(
    R.prop("external_id"),
    R.find(R.propEq("payment_provider_id", externalProviderID))
  )(external_fees);
  return retVal || null;
}
