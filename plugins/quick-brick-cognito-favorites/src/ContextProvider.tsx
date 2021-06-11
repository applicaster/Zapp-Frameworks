/// <reference types="@applicaster/applicaster-types" />

import React, { useState, useCallback } from "react";
import * as R from "ramda";

import { usePickFromState } from "@applicaster/zapp-react-native-redux/hooks";

import { getDatasetData, updateDataset, getPluginConfiguration } from "./utils";
import { defaultAsset, defaultActiveAsset } from "./defaultAssets";
import { Context } from "./Context";
import XRayLogger from "@applicaster/quick-brick-xray";

const logger = new XRayLogger("quick-brick-cognito-favorites", "general");

const activeState = {
  state: 1,
  asset: defaultActiveAsset,
  label: "remove from favourites",
};

const defaultState = {
  state: 0,
  asset: defaultAsset,
  label: "add to favourites",
};

export function ContextProvider(Component: ReactComponent<any>) {
  return function CognitoFavoritesProvider({
    children,
  }: CellActionContextProviderProps) {
    const [state, setState] = useState<ZappEntry[]>([]);
    const { plugins } = usePickFromState(["plugins"]);
    const config = getPluginConfiguration(plugins);

    const isInFavourites = useCallback(
      (entry: ZappEntry) => {
        const entryState = state.map((item) => item.id);

        return R.includes(entry?.id, entryState);
      },
      [state.length]
    );

    const addFavourite = async (entry): Promise<ZappEntry[]> => {
      const datasetParams = {
        state,
        entry,
        config,
      };

      const newFavourites = await updateDataset(datasetParams, false);

      logger.debug({
        message: `Add favorite for id: ${entry?.id}`,
        data: { entry, id: entry?.id, state, config, newFavourites },
      });
      setState(newFavourites);

      return newFavourites;
    };

    const removeFavourite = async (entry): Promise<ZappEntry[]> => {
      const datasetParams = {
        state,
        entry,
        config,
      };

      const newFavourites = await updateDataset(datasetParams, true);
      logger.debug({
        message: `Remove favorite for id: ${entry?.id}`,
        data: { entry, id: entry?.id, state, config, newFavourites },
      });
      setState(newFavourites);

      return newFavourites;
    };

    const getInitialState = useCallback(async () => {
      const favList = await getDatasetData(config);
      setState(favList);
    }, [setState]);

    const invokeAction = useCallback(
      (entry: ZappEntry, options: InvokeArgsOptions) => {
        logger.debug({
          message: `Invoke action`,
          data: { entry, options },
        });
        const { updateState } = options || {};

        if (isInFavourites(entry)) {
          removeFavourite(entry);

          updateState?.(defaultState);
        } else {
          addFavourite(entry);
          updateState?.(activeState);
        }
      },
      [isInFavourites, addFavourite, removeFavourite]
    );

    const initialEntryState = useCallback(
      (entry) => {
        if (isInFavourites(entry)) {
          return activeState;
        }

        return defaultState;
      },
      [isInFavourites]
    );

    return (
      <Context.Provider
        value={{
          state,
          getInitialState,
          invokeAction,
          initialEntryState,
        }}
      >
        <Component>{children}</Component>
      </Context.Provider>
    );
  };
}
