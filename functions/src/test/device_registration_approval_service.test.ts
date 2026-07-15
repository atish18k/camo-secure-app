import assert from "node:assert/strict";
import test from "node:test";
import {Firestore} from "firebase-admin/firestore";
import {
  approveDeviceRegistration,
  parseDeviceApprovalInput,
} from "../services/device_registration_approval_service";

test("approval input rejects malformed document segments", () => {
  assert.throws(() => parseDeviceApprovalInput({userId: "", requestId: "r"}));
  assert.throws(() => parseDeviceApprovalInput({userId: "u", requestId: "a/b"}));
});

test("pending request creates approved device and resolves atomically", async () => {
  const creates: unknown[] = [];
  const updates: unknown[] = [];
  let reads = 0;
  const transaction = {
    get: async () => {
      reads++;
      if (reads === 1) {
        return {exists: true, data: () => ({
          schemaVersion: 1, requestId: "request-1", userId: "user-1",
          deviceId: "device-1", publicKey: "public-key", keyVersion: 1,
          platform: "web", status: "pending",
        })};
      }
      return {exists: false};
    },
    create: (...args: unknown[]) => creates.push(args),
    update: (...args: unknown[]) => updates.push(args),
  };
  const firestore = {
    doc: (path: string) => ({path}),
    runTransaction: async (callback: (value: typeof transaction) => unknown) => callback(transaction),
  } as unknown as Firestore;
  const result = await approveDeviceRegistration(
    firestore, {userId: "user-1", requestId: "request-1"}, "approver-1",
  );
  assert.equal(result.status, "approved");
  assert.equal(creates.length, 1);
  assert.equal(updates.length, 1);
});

test("non-pending request fails closed before device creation", async () => {
  let createCalls = 0;
  const transaction = {
    get: async () => ({exists: true, data: () => ({
      schemaVersion: 1, requestId: "request-1", userId: "user-1", status: "approved",
    })}),
    create: () => { createCalls++; },
    update: () => undefined,
  };
  const firestore = {
    doc: (path: string) => ({path}),
    runTransaction: async (callback: (value: typeof transaction) => unknown) => callback(transaction),
  } as unknown as Firestore;
  await assert.rejects(() => approveDeviceRegistration(
    firestore, {userId: "user-1", requestId: "request-1"}, "approver-1",
  ));
  assert.equal(createCalls, 0);
});