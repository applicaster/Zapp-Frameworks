const common = [
  {
    key: "account_title",
    label: "Account title text",
    initial_value: "Account",
  },
  {
    key: "user_name_title",
    label: "text before user id text",
    initial_value: "User:",
  },
  {
    key: "subscription_title",
    label: "Subscription text title",
    initial_value: "Subscription",
  },
  {
    key: "subscription_expiration_title",
    label: "Subscription expiration title",
    initial_value: "- renews",
  },
  {
    key: "logout_title_text",
    label: "Logout Button title",
    initial_value: "Logout",
  },
  {
    key: "login_button_1_title_text",
    label: "Login Button 1 title",
    initial_value: "Login 1",
  },
  {
    key: "login_button_2_title_text",
    label: "Login Button 2 title",
    initial_value: "Login 2",
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
