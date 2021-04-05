export const productMockResponse = {
  payload: {},
  invalidIDs: [],
  products: [
    {
      contentVersion: "",
      description: "Unlimited access! SAVE 50% & cancel anytime",
      downloadContentLengths: [],
      downloadContentVersion: "",
      isDownloadable: false,
      price: "$5.99",
      productIdentifier: "com.babyfirst.discounted.1month.premium",
      productType: "subscription",
      title: "Premium",
    },
    {
      contentVersion: "",
      description: "Limited offer – SAVE 50%. Cancel anytime.",
      downloadContentLengths: [],
      downloadContentVersion: "",
      isDownloadable: false,
      price: "$3.99",
      productIdentifier: "com.babyfirst.discounted.1month.standard",
      productType: "subscription",
      title: "Standard",
    },
    {
      contentVersion: "",
      description: "Unlimited access! Pay annually, only $3.12/mo",
      downloadContentLengths: [],
      downloadContentVersion: "",
      isDownloadable: false,
      price: "$37.99",
      productIdentifier: "com.babyfirst.discounted.1year.premium",
      productType: "subscription",
      title: "Annual Premium",
    },
    {
      contentVersion: "",
      description: "Save 50%! only $2.08/mo when paying annually",
      downloadContentLengths: [],
      downloadContentVersion: "",
      isDownloadable: false,
      price: "$24.99",
      productIdentifier: "com.babyfirst.discounted.1year.standard",
      productType: "subscription",
      title: "Annual Standard",
    },
  ],
};

export const purchaseMock = {
  receipt: "Base64Reciept",
  transactionIdentifier: "123456789",
};

export const restoreProductsMock = {
  receipt: "Base64Reciept",
  restoredProducts: [
    "com.babyfirst.discounted.1month.premium",
    "com.babyfirst.discounted.1month.standard",
    "com.babyfirst.discounted.1year.premium",
    "com.babyfirst.discounted.1year.standard",
  ],
};
