import AWS from "aws-sdk";
import * as R from "ramda";
import "@applicaster/amazon-cognito-js";

import { localStorage } from "@applicaster/zapp-react-native-bridge/ZappStorage/LocalStorage";
import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";
import { populateConfigurationValues } from "@applicaster/zapp-react-native-utils/stylesUtils";
import XRayLogger from "@applicaster/quick-brick-xray";

const logger = new XRayLogger("quick-brick-cognito-favorites", "general");
const COGNITO_NAMESPACE = "cognito-webview-login";
const PLUGIN_IDENTIFIER = "cognito-favorites";

const getManifestProperties = () => {
  return platformSelect({
    ios: require("../manifests/ios_for_quickbrick.json"),
    android: require("../manifests/android_for_quickbrick.json"),
    default: require("../manifests/ios_for_quickbrick.json"),
  });
};

const initializeConfig = (pluginConfiguration = {}) => {
  const { custom_configuration_fields: generalProps } = getManifestProperties();

  const defaultProps = populateConfigurationValues(generalProps)(
    pluginConfiguration || {}
  );

  return R.mergeDeepRight(defaultProps, pluginConfiguration || {});
};

export const getPluginConfiguration = R.compose(
  initializeConfig,
  R.unless(R.isNil, R.prop("configuration")),
  R.find(R.propEq("identifier", PLUGIN_IDENTIFIER))
);

const handleSync = (dataset, callback) => {
  dataset.synchronize({
    onSuccess: (dataset, newRecords) => {
      logger.debug({
        message: `dataset.synchronize onSuccess: Synchronized successfully`,
      });

      if (callback) {
        callback(dataset);
      }
    },
    onFailure: (err) => {
      if (callback) {
        callback(null, true);
      }
    },
    onConflict: function (dataset, conflicts, callback) {
      logger.debug({
        message: `dataset.synchronize onConflict: Resolving conflict, resolveWithRemoteRecord!!!`,
        data: { conflicts, callback },
      });
      var resolved = [];

      for (var i = 0; i < conflicts.length; i++) {
        // Take remote version.
        resolved.push(conflicts[i].resolveWithRemoteRecord());

        // Or... take local version.
        // resolved.push(conflicts[i].resolveWithLocalRecord());

        // Or... use custom logic.
        // var newValue = conflicts[i].getRemoteRecord().getValue() + conflicts[i].getLocalRecord().getValue();
        // resolved.push(conflicts[i].resovleWithValue(newValue);
      }

      dataset.resolve(resolved, function () {
        return callback(true);
      });

      // Or... callback false to stop the synchronization process.
      // return callback(false);
    },
  });
};

const initAwsAuth = async (configuration) => {
  const {
    identity_pool_id: identityPoolId,
    region: awsRegion,
    cognito_access_token_key: cognitoToken,
    cognito_access_token: accessToken,
    cognito_auth_provider_key: cognitoAuthProvider,
    cognito_auth_provider: authProvider,
  } = configuration;

  const cognitoAccessToken =
    accessToken ||
    (await localStorage.getItem(cognitoToken, COGNITO_NAMESPACE));

  const cognitoProvider =
    authProvider ||
    (await localStorage.getItem(cognitoAuthProvider, COGNITO_NAMESPACE));

  AWS.config.region = awsRegion;

  AWS.config.credentials = new AWS.CognitoIdentityCredentials({
    IdentityPoolId: identityPoolId,
    Logins: {
      [cognitoProvider]: cognitoAccessToken,
    },
  });
};

export const getDatasetData = async (configuration) => {
  const { cognito_dataset_name, cognito_dataset_key } = configuration;

  await initAwsAuth(configuration);

  const getData: Promise<ZappEntry[]> = new Promise((resolve) => {
    // @ts-ignore

    AWS.config.credentials.get(() => {
      // @ts-ignore
      const client = new AWS.CognitoSyncManager();

      client.openOrCreateDataset(cognito_dataset_name, async (err, dataset) => {
        if (err) {
          return;
        }

        logger.debug({
          message: `client.openOrCreateDataset: Success`,
        });
        const fetchData = (newDataset, syncErr) => {
          if (syncErr) {
            resolve([]);
          }

          if (newDataset) {
            newDataset.get(cognito_dataset_key, (err, value) => {
              if (!err) {
                resolve(value ? JSON.parse(value) : []);
              }

              logger.info({
                message: `newDataset.get : Success value: ${value}`,
                data: { cognito_dataset_key, value },
              });
            });
          }
        };

        handleSync(dataset, fetchData);
      });
    });
  });

  const data = await getData;

  return data;
};

export const updateDataset = async (params, remove) => {
  const { state, entry, config } = params;
  const { cognito_dataset_name, cognito_dataset_key } = config;

  await initAwsAuth(config);

  const getData: Promise<ZappEntry[]> = new Promise((resolve) => {
    // @ts-ignore

    AWS.config.credentials.get(() => {
      // @ts-ignore
      const client = new AWS.CognitoSyncManager();

      client.openOrCreateDataset(cognito_dataset_name, async (err, dataset) => {
        if (err) {
          return;
        }

        logger.info({
          message: `client.openOrCreateDataset: Success`,
        });
        let payload;

        const entryData = (item) => ({
          id: item.id,
          timestamp: Date.now(),
        });

        if (remove) {
          payload = state
            .filter((item) => item.id !== entry.id)
            .map((item) => entryData(item));
        } else {
          payload = [...state, entryData(entry)];
        }

        const normalizedPayload = JSON.stringify(payload);

        logger.info({
          message: `client.openOrCreateDataset prepare payload`,
          data: { payload, entryData, normalizedPayload },
        });

        dataset.put(cognito_dataset_key, normalizedPayload, (err, value) => {
          if (!err) {
            resolve(JSON.parse(value.value));
          }

          logger.info({
            message: `dataset.put: Succeed value: ${value}`,
            data: { payload, entryData, normalizedPayload },
          });
        });

        handleSync(dataset, null);
      });
    });
  });

  const data = await getData;

  return data;
};
