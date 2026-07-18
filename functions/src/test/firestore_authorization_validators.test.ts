import assert from "node:assert/strict";
import test from "node:test";

import {
  CamoAuthorizationDocument,
  CamoAuthorizationDocumentReader,
} from "../infrastructure/authorization_document_reader";
import {
  FirestoreCamoDeviceAuthorizationPort,
} from "../validators/firestore_device_authorization_port";
import {
  FirestoreCamoEntitlementAuthorizationPort,
} from "../validators/firestore_entitlement_authorization_port";
import {
  FirestoreCamoPairAuthorizationPort,
} from "../validators/firestore_pair_authorization_port";
import {
  FirestoreCamoPolicyAuthorizationPort,
} from "../validators/firestore_policy_authorization_port";
import {
  FirestoreCamoRiskAuthorizationPort,
} from "../validators/firestore_risk_authorization_port";
import {
  FirestoreCamoUserAuthorizationPort,
} from "../validators/firestore_user_authorization_port";

const context = {
  requestId: "request-001",
  operationId: "operation-001",
  userId: "user-001",
  deviceId: "device-001",
  operationType: "encode" as const,
  pairId: "pair-001",
  keyPurpose: "messageEncryption",
  keyScope: "message",
  requiredEntitlements: ["baseEncoding"],
  requestedAt: "2026-07-13T12:00:00.000Z",
  serverReceivedAt: "2026-07-13T12:00:01.000Z",
};

class FakeReader implements CamoAuthorizationDocumentReader {
  constructor(
    private readonly documents:
      Readonly<Record<string, CamoAuthorizationDocument>>,
  ) {}

  async readDocument(
    path: string,
  ): Promise<CamoAuthorizationDocument | null> {
    return this.documents[path] ?? null;
  }
}

test("user validator allows only active bound user", async () => {
  const validator = new FirestoreCamoUserAuthorizationPort(
    new FakeReader({
      "users/user-001": {
        uid: "user-001",
        disabled: false,
        status: "active",
      },
    }),
  );

  const result = await validator.validateUser(context);

  assert.equal(result.allowed, true);
  assert.equal(result.reasonCode, "server_user_valid");
});

test("device validator denies revoked device", async () => {
  const validator = new FirestoreCamoDeviceAuthorizationPort(
    new FakeReader({
      "users/user-001/devices/device-001": {
        deviceId: "device-001",
        userId: "user-001",
        status: "active",
        approved: true,
        revoked: true,
        publicKey: "public-key",
      },
    }),
  );

  const result = await validator.validateDevice(context);

  assert.equal(result.allowed, false);
  assert.equal(
    result.reasonCode,
    "server_trusted_device_not_approved",
  );
});

test("pair validator validates active participant", async () => {
  const validator = new FirestoreCamoPairAuthorizationPort(
    new FakeReader({
      "pairings/pair-001": {
        pairId: "pair-001",
        status: "active",
        active: true,
        participantUserIds: ["user-001", "user-002"],
      },
    }),
  );

  const result = await validator.validatePair(context);

  assert.equal(result.allowed, true);
});

test("policy validator requires online authorization", async () => {
  const validator = new FirestoreCamoPolicyAuthorizationPort(
    new FakeReader({
      "enterprisePolicies/global": {
        enabled: true,
        onlineAuthorizationRequired: true,
        offlineOperationsAllowed: false,
        allowedOperations: ["encode", "decode"],
      },
    }),
  );

  const result = await validator.evaluatePolicy(context);

  assert.equal(result.allowed, true);
});

test("risk validator requires explicit allow decision", async () => {
  const validator = new FirestoreCamoRiskAuthorizationPort(
    new FakeReader({
      "enterpriseRiskDecisions/operation-001": {
        schemaVersion: 1,
        operationId: "operation-001",
        userId: "user-001",
        deviceId: "device-001",
        pairId: "pair-001",
        decision: "allow",
        permitsOperation: true,
        createdAt: "2026-07-13T11:59:00.000Z",
        expiresAt: "2026-07-13T12:01:00.000Z",
      },
    }),
  );

  const result = await validator.evaluateRisk(context);

  assert.equal(result.allowed, true);
});

test("entitlement validator requires all entitlements", async () => {
  const validator =
    new FirestoreCamoEntitlementAuthorizationPort(
      new FakeReader({
        "users/user-001/commercialAccess/current": {
          userId: "user-001",
          subscriptionActive: true,
          grantedEntitlements: [
            "baseEncoding",
            "baseDecoding",
          ],
          expiresAt: "2026-07-14T12:00:00.000Z",
        },
      }),
      () => new Date("2026-07-13T12:00:00.000Z"),
    );

  const result = await validator.validateEntitlements(context);

  assert.equal(result.allowed, true);
});

test("missing Firestore document always denies", async () => {
  const reader = new FakeReader({});

  const userValidator =
    new FirestoreCamoUserAuthorizationPort(reader);

  const deviceValidator =
    new FirestoreCamoDeviceAuthorizationPort(reader);

  const pairValidator =
    new FirestoreCamoPairAuthorizationPort(reader);

  const policyValidator =
    new FirestoreCamoPolicyAuthorizationPort(reader);

  const riskValidator =
    new FirestoreCamoRiskAuthorizationPort(reader);

  const entitlementValidator =
    new FirestoreCamoEntitlementAuthorizationPort(reader);

  const decisions = await Promise.all([
    userValidator.validateUser(context),
    deviceValidator.validateDevice(context),
    pairValidator.validatePair(context),
    policyValidator.evaluatePolicy(context),
    riskValidator.evaluateRisk(context),
    entitlementValidator.validateEntitlements(context),
  ]);

  assert.equal(decisions.length, 6);

  for (const decision of decisions) {
    assert.equal(decision.allowed, false);
  }
});
