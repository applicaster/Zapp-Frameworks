/// <reference types=".." />
/// <reference types="@applicaster/applicaster-types" />

import { Context } from "./Context";
import { ContextProvider } from "./ContextProvider";
import { getDataSource } from "./getDataSource";

const FavouritesCellAction: CellActionPlugin<FavouritesContext> = {
  actionName: "favourites",
  contextProvider: ContextProvider,
  context: Context,
  getDataSource,
};

export default FavouritesCellAction;
