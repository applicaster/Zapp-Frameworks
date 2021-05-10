const common = [
  // Action buttons
  {
    key: "back_button_text",
    label: "Back button text",
    initial_value: "Back",
  },
  {
    key: "next_button_text",
    label: "Next button text",
    initial_value: "Next",
  },
  {
    key: "close_button_text",
    label: "Close button text",
    initial_value: "Close",
  },
  {
    key: "sign_in_button_text",
    label: "Sign in button text",
    initial_value: "Sigin In",
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
