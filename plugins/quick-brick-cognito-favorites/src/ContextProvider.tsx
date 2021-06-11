/// <reference types="@applicaster/applicaster-types" />

import React, { useState, useCallback } from "react";
import * as R from "ramda";

import { usePickFromState } from "@applicaster/zapp-react-native-redux/hooks";

import { getDatasetData, updateDataset, getPluginConfiguration } from "./utils";
import { defaultAsset, defaultActiveAsset } from "./defaultAssets";
import { Context } from "./Context";

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
        console.log("isInFavourites", {
          entryState,
          entry,
          entryID: entry?.id,
        });
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
      console.log({ state, entry, config });
      const newFavourites = await updateDataset(datasetParams, false);

      setState(newFavourites);

      return newFavourites;
    };

    const removeFavourite = async (entry): Promise<ZappEntry[]> => {
      console.log("RemoveFavorites", { state, entry, config });
      const datasetParams = {
        state,
        entry,
        config,
      };

      const newFavourites = await updateDataset(datasetParams, true);

      setState(newFavourites);

      return newFavourites;
    };

    const getInitialState = useCallback(async () => {
      const favList = await getDatasetData(config);
      setState(favList);
    }, [setState]);

    const invokeAction = useCallback(
      (entry: ZappEntry, options: InvokeArgsOptions) => {
        console.log("INVOKE ACTION", { entry, options });
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
