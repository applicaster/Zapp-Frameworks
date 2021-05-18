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
