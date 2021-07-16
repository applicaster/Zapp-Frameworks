const userId = "a.kononeenko@applicaster.com";
const subscriptionStart = "Monthly $3.99";
const subscriptionEnd = "5/5/2021";

export function getUserId(title): string {
  return `${title} ${userId}`;
}

export function getSubscriptionData(title): string {
  return `${subscriptionStart} ${title} ${subscriptionEnd}`;
}

export async function login() {
  return Promise.resolve(true);
}

export async function logout() {
  return Promise.resolve(true);
}
