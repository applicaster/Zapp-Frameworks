#!/usr/bin/env node

const common = [
  {
    key: "title_text",
    label: "Title label text",
    initial_value: "My Company",
  },
  {
    key: "subtitle_text",
    label: "Subtitle label text",
    initial_value: "Subtitle",
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
    label: "Alert fail title",
    initial_value: "Error",
  },
  {
    key: "alert_login_fail_message",
    label: "Alert message on user failed to authenticate",
    initial_value: "Authentication failed",
  },
  {
    key: "alert_logout_fail_message",
    label: "Alert message on user failed to revoke access",
    initial_value: "Logout failed",
  },
  {
    key: "alert_succeed_title",
    label: "Alert succeed title",
    initial_value: "Success",
  },
  {
    key: "alert_login_succeed_message",
    label: "Alert message on successful authentication",
    initial_value: "Authentication completed",
  },
  {
    key: "alert_logout_succeed_message",
    label: "Alert message on successful authentication",
    initial_value: "Logout completed",
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
