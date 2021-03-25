import { getLocalizations as getCurrentLocalizations } from "@applicaster/zapp-react-native-utils/appUtils/localizationsHelper";
import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";
const Localizations = require("../../../manifests/localizations.config");

const getConfig = () =>
  platformSelect({
    ios: Localizations.mobile.fields,
    android: Localizations.mobile.fields,
    default: Localizations.tv.fields,
  });

const getDefaultLocalizations = () => {
  console.log({ Localizations });
  return getConfig().reduce((acc, { key, initial_value }) => {
    acc[key] = initial_value;
    return acc;
  }, {});
};

export const getLocalizations = (localizations) => {
  const currentValues = getCurrentLocalizations({ localizations });
  const defaultValues = getDefaultLocalizations();

  return { ...defaultValues, ...currentValues };
};
