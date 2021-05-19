#!/usr/bin/env node

const common = [
  {
    key: "title_text",
    label: "Main screen title to screen",
    initial_value: "WELCOME TO THE MY APPLICATION",
  },
  {
    key: "title_text_hook",
    label: "Main screen title to screen hook",
    initial_value:
      "Create an account to personalize your my application experience",
  },
  {
    key: "sing_in_button",
    label: "Sign in button text",
    initial_value: "Sign In / Register",
  },
  {
    key: "sing_in_later",
    label: "Sign in later button text",
    initial_value: "Maybe Later",
  },
];

const mobile = [];

const tv = [];

const Localizations = {
  mobile: {
    fields: [...common, ...mobile],
  },
  tv: {
    fields: [...common, ...tv],
  },
};

module.exports = Localizations;
