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
  {
    key: "alert_fail_title",
    label: "Alert title user fail to authenteficate",
    initial_value: "Error",
  },
  {
    key: "alert_fail_message",
    label: "Alert message user fail to authenteficate",
    initial_value: "Authentefication failed",
  },
  {
    key: "alert_succeed_title",
    label: "Alert title user succeed to authenteficate",
    initial_value: "Warning",
  },
  {
    key: "alert_succeed_message",
    label: "Alert message user succeed to authenteficate",
    initial_value: "Authentefication succeed",
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
