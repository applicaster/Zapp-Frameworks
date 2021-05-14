// https://github.com/aws-amplify/amplify-js/blob/master/packages/amazon-cognito-identity-js/src/Client.js
// https://medium.com/tensult/how-to-refresh-aws-cognito-user-pool-tokens-d0e025cedd52
export async function refresh(refreshToken, clientId, region = "eu-west-1") {
  console.log({ refreshToken, clientId, region });
  if (!refreshToken || !region || !clientId) {
    throw Error("Can not refresh Token, no parameters");
  }
  return fetch(`https://cognito-idp.${region}.amazonaws.com/`, {
    headers: {
      "X-Amz-Target": "AWSCognitoIdentityProviderService.InitiateAuth",
      "Content-Type": "application/x-amz-json-1.1",
    },
    mode: "cors",
    cache: "no-cache",
    method: "POST",
    body: JSON.stringify({
      ClientId: clientId,
      AuthFlow: "REFRESH_TOKEN_AUTH",
      AuthParameters: {
        REFRESH_TOKEN: refreshToken,
        //SECRET_HASH: "your_secret", // In case you have configured client secret
      },
    }),
  })
    .then(
      (resp) => {
        response = resp;
        return resp;
      },
      (err) => {
        // If error happens here, the request failed
        // if it is TypeError throw network error
        if (err instanceof TypeError) {
          throw new Error("Network error");
        }
        throw err;
      }
    )
    .then((resp) => {
      return resp.json();
    })
    .then((data) => {
      // return parsed body stream
      if (response.ok) {
        const result = data?.AuthenticationResult;

        return {
          access_token: result?.AccessToken,
          id_token: result?.IdToken,
          expires_in: result?.ExpiresIn,
        };
      }
      responseJsonData = data;

      // Taken from aws-sdk-js/lib/protocol/json.js
      // eslint-disable-next-line no-underscore-dangle
      const code = (data.__type || data.code).split("#").pop();
      const error = {
        code,
        name: code,
        message: data.message || data.Message || null,
      };
      throw error;
    })
    .catch((err) => {
      // first check if we have a service error
      if (
        response &&
        response.headers &&
        response.headers.get("x-amzn-errortype")
      ) {
        try {
          const code = response.headers.get("x-amzn-errortype").split(":")[0];
          const error = {
            code,
            name: code,
            statusCode: response.status,
            message: response.status ? response.status.toString() : null,
          };
          throw error;
        } catch (ex) {
          throw err;
        }
        // otherwise check if error is Network error
      } else if (err instanceof Error && err.message === "Network error") {
        const error = {
          code: "NetworkError",
          name: err.name,
          message: err.message,
        };
        throw error;
      } else {
        throw err;
      }
    });
}
