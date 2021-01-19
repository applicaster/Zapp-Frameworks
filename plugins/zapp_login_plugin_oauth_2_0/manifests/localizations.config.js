#!/usr/bin/env node

const common = [
  {
    key: "title_text",
    label: "Title label text",
    initial_value: "My Company",
  },
  {
    key: "login_text",
    label: "Login button text",
    initial_value: "Login",
  },
  {
    key: "logout_text",
    label: "Logout button text",
    initial_value: "Login",
  },
  {
    key: "back_button_text",
    label: "Back button title",
    initial_value: "Back",
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
