const common = [
  // Fields
  {
    key: "fields_email_text",
    label: "Email field placeholder",
    initial_value: "E-mail",
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
