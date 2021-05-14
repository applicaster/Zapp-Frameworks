import * as R from "ramda";
import {
  createLogger,
  BaseSubsystem,
  BaseCategories,
} from "../../Services/LoggerService";

export const logger = createLogger({
  subsystem: BaseSubsystem,
  category: "",
});

export const isAuthenticationRequired = (payload: ZappEntry) => {
  const requires_authentication = R.path([
    "extensions",
    "requires_authentication",
  ])(payload);

  logger.debug({
    message: `Payload entry is requires_authentication: ${requires_authentication}`,
    data: {
      requires_authentication: requires_authentication,
    },
  });
  return requires_authentication;
};
