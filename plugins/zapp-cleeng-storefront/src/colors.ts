const defaultColors = {
  white: "#ffffff",
  gray: "#7d7d7d",
  grayLight: "#aeaeae",
  grayLighter: "#efefef",
  grayDark: "#41454f",
  red: "#ee0420",
  navyBlue: "#223b63",
  transparent: "transparent",
};

export default {
  ...defaultColors,
  inputBorderColor: defaultColors.grayDark,
  inputBorderColorActive: defaultColors.red,
  buttonActive: defaultColors.red,
};
