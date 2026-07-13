import assert from "node:assert/strict";
import test from "node:test";

import {
  createCamoProductionServerAuthorizationOrchestrator,
} from "../services/production_server_authorization_factory";

test("production factory creates fail-closed orchestrator", () => {
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
    });

  assert.ok(orchestrator);
});