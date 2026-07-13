import {initializeApp} from "firebase-admin/app";
import {setGlobalOptions} from "firebase-functions/v2";
import {HttpsError, onCall} from "firebase-functions/v2/https";

import {
  createFailClosedDenial,
  parseAuthorizationInput,
} from "./authorization_contract";

initializeApp();

setGlobalOptions({
  region: "us-central1",
  maxInstances: 10,
  concurrency: 20,
  timeoutSeconds: 30,
  memory: "256MiB",
});

export const authorizeOperation = onCall(
  {
    enforceAppCheck: true,
    consumeAppCheckToken: true,
  },
  async (request) => {
    if (request.auth === undefined) {
      throw new HttpsError(
        "unauthenticated",
        "Authenticated CAMO user is required.",
      );
    }

    if (request.app === undefined) {
      throw new HttpsError(
        "failed-precondition",
        "Valid Firebase App Check attestation is required.",
      );
    }

    let input;

    try {
      input = parseAuthorizationInput(request.data);
    } catch {
      throw new HttpsError(
        "invalid-argument",
        "Authorization request payload is invalid.",
      );
    }

    if (input.userId !== request.auth.uid) {
      throw new HttpsError(
        "permission-denied",
        "Authorization user binding failed.",
      );
    }

    const denial = createFailClosedDenial();

    throw new HttpsError(
      "failed-precondition",
      "CAMO production authorization is not activated.",
      denial,
    );
  },
);