import assert from "node:assert/strict";
import test from "node:test";
import {Firestore} from "firebase-admin/firestore";
import {
  approveDeviceRegistration,
  parseDeviceApprovalInput,
} from "../services/device_registration_approval_service";

test("approval input rejects invalid segments", () => {
  assert.throws(() => parseDeviceApprovalInput(null));
  assert.throws(() => parseDeviceApprovalInput({userId: "", requestId: "r"}));
  assert.throws(() => parseDeviceApprovalInput({userId: "u", requestId: "a/b"}));
});

test("approval creates canonical device and supersedes duplicate pending requests", async () => {
  const updates: Array<{id: string; value: Record<string, unknown>}> = [];
  const creates: Array<Record<string, unknown>> = [];
  const selectedRef = {id: "request-2", kind: "request"};
  const oldRef = {id: "request-1", kind: "sibling"};
  const deviceRef = {id: "device-1", kind: "device"};
  const query = {kind: "query"};
  const collection = {
    doc: () => selectedRef,
    where: () => ({where: () => query}),
  };
  const transaction = {
    get: async (target: {kind: string}) => {
      if (target.kind === "request") return {
        exists: true,
        data: () => ({
          schemaVersion: 1, requestId: "request-2", userId: "user-1",
          deviceId: "device-1", publicKey: "public-key", keyVersion: 1,
          platform: "web", status: "pending",
        }),
      };
      if (target.kind === "query") return {docs: [
        {id: "request-1", ref: oldRef},
        {id: "request-2", ref: selectedRef},
      ]};
      return {exists: false};
    },
    create: (_ref: unknown, value: Record<string, unknown>) => creates.push(value),
    update: (ref: {id: string}, value: Record<string, unknown>) => updates.push({id: ref.id, value}),
  };
  const firestore = {
    collection: () => collection,
    doc: () => deviceRef,
    runTransaction: async (callback: (value: typeof transaction) => unknown) => callback(transaction),
  } as unknown as Firestore;

  const result = await approveDeviceRegistration(
    firestore, {userId: "user-1", requestId: "request-2"}, "approver-1",
  );
  assert.equal(result.status, "approved");
  assert.equal(result.supersededRequestCount, 1);
  assert.equal(creates.length, 1);
  assert.equal(updates.find((item) => item.id === "request-1")?.value.status, "rejected");
  assert.equal(updates.find((item) => item.id === "request-1")?.value.resolutionReason, "superseded");
  assert.equal(updates.find((item) => item.id === "request-2")?.value.status, "approved");
});

test("approval rejects a non-pending request", async () => {
  const requestRef = {id: "request-1", kind: "request"};
  const transaction = {
    get: async () => ({
      exists: true,
      data: () => ({
        schemaVersion: 1, requestId: "request-1", userId: "user-1",
        status: "approved",
      }),
    }),
  };
  const firestore = {
    collection: () => ({doc: () => requestRef}),
    runTransaction: async (callback: (value: typeof transaction) => unknown) => callback(transaction),
  } as unknown as Firestore;
  await assert.rejects(() => approveDeviceRegistration(
    firestore, {userId: "user-1", requestId: "request-1"}, "approver-1",
  ));
});