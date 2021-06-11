/// <reference types="@applicaster/applicaster-types" />

import React from "react";
import { View, ActivityIndicator, StyleSheet } from "react-native";
import AWS from "aws-sdk";
import "@applicaster/amazon-cognito-js";
import XRayLogger from "@applicaster/quick-brick-xray";
import { playerManager } from "@applicaster/zapp-react-native-utils/appUtils/playerManager";
import { localStorage } from "@applicaster/zapp-react-native-bridge/ZappStorage/LocalStorage";

const logger = new XRayLogger("Cognito Watchlist", "plugin");

type Props = {
  payload: ZappEntry;
  callback: Callback;
  configuration: Configuration;
};

type Configuration = {
  identity_pool_id: string;
  region: string;
  cognito_access_token_key: string;
  cognito_access_token: string;
  cognito_auth_provider_key: string;
  cognito_auth_provider: string;
  cognito_dataset_name: string;
};

type Callback = ({ success: boolean, payload: ZappEntry }) => void;

const COGNITO_NAMESPACE = "cognito-webview-login";

function ContinueWatching(props: Props) {
  let progress = null;
  let duration = null;

  const { payload, callback, configuration } = props;

  const handleSync = (dataset, callback) => {
    dataset.synchronize({
      onSuccess: (newDataset) => {
        logger.debug({
          message: "ContinueWatching Synchronized successfully",
        });

        if (callback) {
          callback(newDataset);
        }
      },
      onFailure: (err) => {
        logger.error({
          message: `ContinueWatching Synchronization failed: ${err.message}`,
          data: { error: err },
        });

        if (callback) {
          callback(null, true);
        }
      },
      onConflict: function (dataset, conflicts, callback) {
        console.log({ dataset, conflicts, callback });
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
    });
  };

  const removeHyphens = (id) => {
    return id.split("-").join("");
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

  const saveRemoteProgress = async (payload: ZappEntry) => {
    const { cognito_dataset_name } = configuration;
    await initAwsAuth(configuration);

    let progressTime = progress || 0;
    progressTime = Math.floor(progressTime);

    if (progressTime >= duration) {
      progressTime = 0;
    }

    logger.debug({
      message: `saveRemoteProgress: ${progressTime}`,
      data: { progressTime, duration, cognito_dataset_name },
    });

    // @ts-ignore
    AWS.config.credentials.get(() => {
      // @ts-ignore
      const client = new AWS.CognitoSyncManager();

      client.openOrCreateDataset(cognito_dataset_name, (err, dataset) => {
        if (err) {
          logger.error({
            message: `client.openOrCreateDataset: Error ${err.message}`,
            data: {
              progressTime,
              duration,
              cognito_dataset_name,
              dataset,
              err,
            },
          });

          return;
        }

        logger.debug({
          message: "client.openOrCreateDataset: Success",
          data: { progressTime, duration, cognito_dataset_name, dataset },
        });

        const { id } = payload;
        let fixedId = removeHyphens(id);

        dataset.put(fixedId, `${progressTime}`, (err, record) => {
          if (err) {
            logger.debug({
              message: `dataset.put: Error ${err.message}`,
              data: {
                progressTime,
                duration,
                cognito_dataset_name,
                record,
                fixedId,
                err,
              },
            });

            throw err;
          }

          logger.debug({
            message: "dataset.put: Success",
            data: { progressTime, duration, cognito_dataset_name, record },
          });

          return record;
        });

        handleSync(dataset, null);
      });
    });
  };

  const getRemoteProgress = async (payload: ZappEntry) => {
    const { cognito_dataset_name } = configuration;

    await initAwsAuth(configuration);

    const remoteProgress = await new Promise((resolve, reject) => {
      // @ts-ignore
      AWS.config.credentials.get(() => {
        // @ts-ignore
        const client = new AWS.CognitoSyncManager();

        client.openOrCreateDataset(cognito_dataset_name, (err, dataset) => {
          if (err) reject(err);

          const getProgress = (newDataset, error) => {
            if (error) resolve(0);

            const { id } = payload;
            let fixedId = removeHyphens(id);

            if (newDataset) {
              newDataset.get(fixedId, (err, value) => {
                resolve(err ? 0 : value);
              });
            }
          };

          handleSync(dataset, getProgress);
        });
      });
    });

    logger.debug({
      message: `getRemoteProgress: ${remoteProgress}`,
    });

    return remoteProgress;
  };

  const initialSync = async (payload: ZappEntry, callback: Callback) => {
    const { extensions } = payload;

    progress = await getRemoteProgress(payload);

    if (!progress) {
      saveRemoteProgress(payload);
    }

    callback({
      success: true,
      payload: {
        ...payload,
        extensions: {
          ...extensions,
          resumeTime: progress || extensions.resumeTime,
        },
      },
    });
  };

  function reportProgress({ currentTime }) {
    duration = playerManager.getDuration();
    progress = currentTime;
  }

  const handleClose = (payload) => {
    saveRemoteProgress(payload);
  };

  const initPlayerManager = async () => {
    playerManager
      .on("ended", () => handleClose(payload))
      .on("close", () => handleClose(payload))
      .on("timeupdate", (currentTime) => reportProgress(currentTime));

    await initialSync(payload, callback);
  };

  React.useEffect(() => {
    initPlayerManager();
  }, []);

  const styles = StyleSheet.create({
    container: {
      flex: 1,
      alignItems: "center",
      justifyContent: "center",
    },
  });

  return (
    <View style={styles.container}>
      <ActivityIndicator />
    </View>
  );
}

export default ContinueWatching;
