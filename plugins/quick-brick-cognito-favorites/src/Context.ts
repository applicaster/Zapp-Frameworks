import { createContext } from "react";

const initialContext = {
  invokeAction: () => {},
  getInitialState: () => Promise.resolve(),
};

export const Context = createContext<FavouritesContext>(initialContext);
