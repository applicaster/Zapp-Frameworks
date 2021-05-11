const { resolve } = require("path");
const R = require("ramda");

const packages = [
  "zapp-react-native-theo-player",
  "zapp-cleeng-login",
  "zapp-cleeng-storefront",
  "zapp-sbs-authentefication",
];

const buildExtraNodeModules = (extraNodeModules, packageName) => {
  return R.assoc(
    `@applicaster/${packageName}`,
    resolve(__dirname, "./plugins/", packageName),
    extraNodeModules
  );
};

const resolveLocalPackages = (packageName) =>
  resolve(__dirname, `./plugins/${packageName}`);

const config = {
  resolver: {
    extraNodeModules: {
      "react-native": resolve(__dirname, "./node_modules/react-native"),
      ...R.reduce(buildExtraNodeModules, {}, packages),
    },
  },
  watchFolders: R.compose(
    R.append(resolve(__dirname)),
    R.map(resolveLocalPackages)
  )(packages),
};

module.exports = config;
