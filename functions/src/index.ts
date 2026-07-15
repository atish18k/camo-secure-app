import {randomUUID} from "node:crypto";

import {initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import {setGlobalOptions} from "firebase-functions/v2";
import {provisionControlledCanaryPair} from "./services/canary_pair_provisioning_service";
import {
  approveDeviceRegistration,
  parseDeviceApprovalInput,
} from "./services/device_registration_approval_service";
import {HttpsError, onCall} from "firebase-functions/v2/https";

import {
  createFailClosedDenial,
  parseAuthorizationInput,
} from "./authorization_contract";
import {
  CamoServerAuthorizationContext,
} from "./domain/authorization_types";
import {
  createCamoProductionServerAuthorizationOrchestrator,
} from "./services/production_server_authorization_factory";
import {
  camoProductionSecurityConfig,
} from "./config/production_security_config";

initializeApp();

setGlobalOptions({
  region: camoProductionSecurityConfig.region,
  serviceAccount:
    camoProductionSecurityConfig.runtimeServiceAccount,
  maxInstances: 10,
  concurrency: 20,
  timeoutSeconds: 30,
  memory: "256MiB",
});

const firestore = getFirestore();

const authorizationOrchestrator =
  createCamoProductionServerAuthorizationOrchestrator({
    firestore,
    idGenerator: randomUUID,
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

    const context: CamoServerAuthorizationContext =
      Object.freeze({
        requestId: input.requestId,
        operationId: input.operationId,
        userId: input.userId,
        deviceId: input.deviceId,
        operationType: input.operationType,
        pairId: input.pairId,
        messageId: input.messageId,
        keyPurpose: input.keyPurpose,
        keyScope: input.keyScope,
        requiredEntitlements: input.requiredEntitlements,
        requestedAt: input.requestedAt,
        serverReceivedAt: new Date().toISOString(),
      });

    let result;

    try {
      result = await authorizationOrchestrator.authorize(context);
    } catch {
      const denial = createFailClosedDenial();

      throw new HttpsError(
        "internal",
        "CAMO authorization pipeline failed closed.",
        denial,
      );
    }

    if (
      !result.authorized ||
      result.signedResponse === undefined
    ) {
      throw new HttpsError(
        "permission-denied",
        "CAMO server authorization was denied.",
        {
          authorized: false,
          reasonCode:
            result.reasonCode.trim() ||
            "server_authorization_denied",
          serverTime: new Date().toISOString(),
        },
      );
    }

    throw new HttpsError(
      "failed-precondition",
      "CAMO production authorization activation remains blocked.",
      createFailClosedDenial(),
    );
  },
);

export const approveDeviceRegistrationRequest = onCall(
  {enforceAppCheck: true, consumeAppCheckToken: true},
  async (request) => {
    if (request.auth === undefined) {
      throw new HttpsError("unauthenticated", "Authenticated approver is required.");
    }
    if (request.app === undefined) {
      throw new HttpsError("failed-precondition", "Valid App Check is required.");
    }
    if (request.auth.token.camoDeviceApprover !== true) {
      throw new HttpsError("permission-denied", "Trusted device approver role is required.");
    }
    let input;
    try {
      input = parseDeviceApprovalInput(request.data);
    } catch {
      throw new HttpsError("invalid-argument", "Device approval payload is invalid.");
    }
    try {
      return await approveDeviceRegistration(firestore, input, request.auth.uid);
    } catch {
      throw new HttpsError("failed-precondition", "Device approval failed closed.");
    }
  },
);

export const provisionCanaryPair = onCall(
  {enforceAppCheck: true, consumeAppCheckToken: true},
  async (request) => {
    if (request.auth === undefined) throw new HttpsError("unauthenticated", "Authentication required.");
    if (request.app === undefined) throw new HttpsError("failed-precondition", "Valid App Check required.");
    if (request.auth.token.camoPairProvisioner !== true) throw new HttpsError("permission-denied", "Canary provisioner claim required.");
    try { return await provisionControlledCanaryPair(firestore, request.auth.uid); }
    catch { throw new HttpsError("failed-precondition", "Canary provisioning failed closed."); }
  },
);