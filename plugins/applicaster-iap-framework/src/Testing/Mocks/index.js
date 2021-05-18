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

export const restoreProductsMockiOS = {
  receipt: "Base64Reciept",
  restoredProducts: [
    "com.babyfirst.discounted.1month.premium",
    "com.babyfirst.discounted.1month.standard",
    "com.babyfirst.discounted.1year.premium",
    "com.babyfirst.discounted.1year.standard",
  ],
  products: [
    {
      productIdentifier: "com.babyfirst.discounted.1month.premium",
      transactionIdentifier: "1",
    },
    {
      productIdentifier: "com.babyfirst.discounted.1month.standard",
      transactionIdentifier: "2",
    },
    {
      productIdentifier: "com.babyfirst.discounted.1year.premium",
      transactionIdentifier: "3",
    },
    {
      productIdentifier: "com.babyfirst.discounted.1year.standard",
      transactionIdentifier: "4",
    },
  ],
};

export const restoreProductsMockAndroid = [
  {
    receipt:
      '{"orderId":"GPA.3316-2382-9492-23216","packageName":"com.applicaster.il.babyfirsttv","productId":"com.babyfirst.discounted.1month.premium","purchaseTime":1617832687002,"purchaseState":0,"purchaseToken":"jkalfijpbicpjmhnfnbnnhma.AO-J1OwgpDYl48ic8wdd3Ah1hnSJCcyGkHxqAPXPibP_jn6kQazMIYDSW1Ktx7ah6ONovm8TCKoWAkLz2L30-pfC2ZVP3OogMUkFbWqDrHtT57MfGjriuss","autoRenewing":true,"acknowledged":true,"transactionIdentifier":"jkalfijpbicpjmhnfnbnnhma.AO-J1OwgpDYl48ic8wdd3Ah1hnSJCcyGkHxqAPXPibP_jn6kQazMIYDSW1Ktx7ah6ONovm8TCKoWAkLz2L30-pfC2ZVP3OogMUkFbWqDrHtT57MfGjriuss","productIdentifier":"com.babyfirst.discounted.1month.standard"}',
  },
  {
    receipt:
      '{"orderId":"GPA.3316-2382-9492-23216","packageName":"com.applicaster.il.babyfirsttv","productId":"com.babyfirst.discounted.1month.standard","purchaseTime":1617832687002,"purchaseState":0,"purchaseToken":"jkalfijpbicpjmhnfnbnnhma.AO-J1OwgpDYl48ic8wdd3Ah1hnSJCcyGkHxqAPXPibP_jn6kQazMIYDSW1Ktx7ah6ONovm8TCKoWAkLz2L30-pfC2ZVP3OogMUkFbWqDrHtT57MfGjriuss","autoRenewing":true,"acknowledged":true,"transactionIdentifier":"jkalfijpbicpjmhnfnbnnhma.AO-J1OwgpDYl48ic8wdd3Ah1hnSJCcyGkHxqAPXPibP_jn6kQazMIYDSW1Ktx7ah6ONovm8TCKoWAkLz2L30-pfC2ZVP3OogMUkFbWqDrHtT57MfGjriuss","productIdentifier":"com.babyfirst.discounted.1month.standard"}',
  },
  {
    receipt:
      '{"orderId":"GPA.3316-2382-9492-23216","packageName":"com.applicaster.il.babyfirsttv","productId":"com.babyfirst.discounted.1year.premium","purchaseTime":1617832687002,"purchaseState":0,"purchaseToken":"jkalfijpbicpjmhnfnbnnhma.AO-J1OwgpDYl48ic8wdd3Ah1hnSJCcyGkHxqAPXPibP_jn6kQazMIYDSW1Ktx7ah6ONovm8TCKoWAkLz2L30-pfC2ZVP3OogMUkFbWqDrHtT57MfGjriuss","autoRenewing":true,"acknowledged":true,"transactionIdentifier":"jkalfijpbicpjmhnfnbnnhma.AO-J1OwgpDYl48ic8wdd3Ah1hnSJCcyGkHxqAPXPibP_jn6kQazMIYDSW1Ktx7ah6ONovm8TCKoWAkLz2L30-pfC2ZVP3OogMUkFbWqDrHtT57MfGjriuss","productIdentifier":"com.babyfirst.discounted.1month.standard"}',
  },
  {
    receipt:
      '{"orderId":"GPA.3316-2382-9492-23216","packageName":"com.applicaster.il.babyfirsttv","productId":"com.babyfirst.discounted.1year.standard","purchaseTime":1617832687002,"purchaseState":0,"purchaseToken":"jkalfijpbicpjmhnfnbnnhma.AO-J1OwgpDYl48ic8wdd3Ah1hnSJCcyGkHxqAPXPibP_jn6kQazMIYDSW1Ktx7ah6ONovm8TCKoWAkLz2L30-pfC2ZVP3OogMUkFbWqDrHtT57MfGjriuss","autoRenewing":true,"acknowledged":true,"transactionIdentifier":"jkalfijpbicpjmhnfnbnnhma.AO-J1OwgpDYl48ic8wdd3Ah1hnSJCcyGkHxqAPXPibP_jn6kQazMIYDSW1Ktx7ah6ONovm8TCKoWAkLz2L30-pfC2ZVP3OogMUkFbWqDrHtT57MfGjriuss","productIdentifier":"com.babyfirst.discounted.1month.standard"}',
  },
];
