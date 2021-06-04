import * as R from "ramda";
import { createLogger, BaseSubsystem, BaseCategories } from "../LoggerService";

const logger = createLogger({
  category: BaseCategories.DRM,
  subsystem: BaseSubsystem,
});

export function getDRMData({ entry }) {
  const drmData = getDRMFromEntry(entry);

  if (drmData) {
    return mapDRMToTheoData(drmData);
  }

  return null;
}

function getDRMFromEntry(entry) {
  return R.path(["extensions", "drm"])(entry);
}

function mapDRMToTheoData(drmData) {
  let retVal = {};
  console.log({ drmData });
  retVal["customdata"] = drmData?.customParams?.custom_data;

  const fairplay = drmData?.fairplay;
  if (fairplay) {
    retVal["fairplay"] = {
      licenseAcquisitionURL: fairplay?.license_server_url,
      certificateURL: fairplay?.certificate_url,
    };
  }

  const playreadyCerteficateURL = drmData?.playready?.license_url;
  if (playreadyCerteficateURL) {
    retVal["playready"] = { licenseAcquisitionURL: playreadyCerteficateURL };
  }

  const widevineCerteficateURL = drmData?.widevine?.license_url;
  if (widevineCerteficateURL) {
    retVal["widevine"] = { licenseAcquisitionURL: playreadyCerteficateURL };
  }

  const integrationPlayready = playreadyCerteficateURL?.extensions?.integration;
  const integrationWidevine = widevineCerteficateURL?.extensions?.integration;
  const integrationFairplay = fairplay?.extensions?.integration;

  const integrationSet = new Set();
  if (integrationFairplay) {
    integrationSet.add(integrationFairplay);
  }
  if (integrationWidevine) {
    integrationSet.add(integrationWidevine);
  }
  if (integrationPlayready) {
    integrationSet.add(integrationPlayready);
  }

  if (integrationSet.size > 0) {
    retVal["integration"] = integrationSet.values().next().value;
    if (integrationSet.size > 1) {
      logger.warning({
        message: "DRM has different integration type for different provider",
        data: {
          drmData,
        },
      });
    }
  }

  const customdataPlayready = playreadyCerteficateURL?.extensions?.integration;
  const customdataWidevine = widevineCerteficateURL?.extensions?.custom_data;
  const customdataFairplay = fairplay?.extensions?.custom_data;

  const customdataSet = new Set();

  if (customdataFairplay) {
    integrationSet.add(customdataFairplay);
  }
  if (customdataWidevine) {
    integrationSet.add(customdataWidevine);
  }
  if (customdataPlayready) {
    integrationSet.add(customdataPlayready);
  }

  if (customdataSet.size > 0) {
    retVal["customdata"] = customdataSet.values().next().value;
    if (customdataSet.size > 1) {
      logger.warning({
        message: "DRM has different custom data type for different provider",
        data: {
          drmData,
        },
      });
    }
  }

  logger.debug({
    message: "DRM prepared",
    data: {
      drm: retVal,
    },
  });

  return retVal;
}

// let licenseAcquisitionURL: String = "<LICENSE_KEY_URL_FAIRPLAY>"
// let certificateURL: String = "<CERTIFICATE_URL_FAIRPLAY>"
// let token: String = "<TOKEN_FAIRPLAY>"

// {
//     "extensions": {
//         "drm": {
//             "fairplay": {
//                 "certificate_url": "",
//                 "license_server_url": "",
//                 "license_server_request_content_type": "",
//                 "license_server_request_json_object_key": ""
//             }
//             widevine/playready>:
//                 "certificate_url": "some_url_of_the_license"
//               }
//         }
//     }
// }
