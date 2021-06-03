import * as R from "ramda";

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

  retVal["integration"] = drmData?.customParams?.integration;
  retVal["customdata"] = drmData?.customParams?.custom_data;

  const fairplay = drmData?.fairplay;
  if (fairplay) {
    retVal["fairplay"] = {
      licenseAcquisitionURL: fairplay?.license_url,
      certificate_url: fairplay?.certificate_url,
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
