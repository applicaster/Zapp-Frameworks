#!/usr/bin/env node

const common = [
  // Error
  {
    key: "general_error_title",
    label: "General error title",
    initial_value: "Error",
  },
  {
    key: "general_error_message",
    label: "General error message",
    initial_value: "Something went wrong. Please try again later",
  },
  {
    key: "close_button_text",
    label: "Close button text",
    initial_value: "Close",
  },
  // Title Screen
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

  // Sign In
  {
    key: "sing_in_title",
    label: "Sign in screen title",
    initial_value: "SIGN IN INTO YOUR APPLICATION ACCOUNT",
  },
  {
    key: "sign_in_go_to_title",
    label: "Go to title",
    initial_value: "Go to:",
  },
  {
    key: "sign_in_activation_code_title",
    label: "Activation code label",
    initial_value: "Enter the activation code below",
  },
  {
    key: "sign_in_support_title",
    label: "Sign in support title",
    initial_value: "If you need support, please visit",
  },
  {
    key: "sign_in_support_link",
    label: "support link",
    initial_value: "google.com",
  },
  // Sign Out
  {
    key: "sing_out",
    label: "Sign Out button text",
    initial_value: "Sign Out",
  },
  {
    key: "sing_out_url_text",
    label: "Sign Out url descriptin",
    initial_value: "To update your account please visit",
  },
  {
    key: "sing_out_url",
    label: "Sign Out url",
    initial_value: "www.google.com",
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
