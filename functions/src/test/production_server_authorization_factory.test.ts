import assert from "node:assert/strict";
import test from "node:test";

import {
  CamoCloudKmsClient,
} from "../kms/camo_cloud_kms_client";
import {
  createCamoProductionServerAuthorizationOrchestrator,
} from "../services/production_server_authorization_factory";

const fakeKmsClient: CamoCloudKmsClient = {
  asymmetricSign: async () => {
    throw new Error("fake_kms_sign_not_invoked");
  },
  getPublicKey: async () => {
    throw new Error("fake_kms_public_key_not_invoked");
  },
  getKeyVersion: async () => {
    throw new Error("fake_kms_version_not_invoked");
  },
};

test("production factory creates KMS-wired orchestrator", () => {
  const fakeFirestore = {
    doc: () => ({
      get: async () => ({
        exists: false,
        data: () => undefined,
      }),
    }),
    collection: () => ({
      doc: () => ({}),
    }),
    runTransaction: async () => false,
  };

  const orchestrator =
    createCamoProductionServerAuthorizationOrchestrator({
      firestore: fakeFirestore as never,
      idGenerator: () => "identifier-001",
      clock: () => new Date("2026-07-13T12:00:00.000Z"),
      kmsClient: fakeKmsClient,
    });

  assert.ok(orchestrator);
});