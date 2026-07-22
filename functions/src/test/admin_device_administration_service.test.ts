import assert from "node:assert/strict";
import test from "node:test";

import {
  parseAdminDeviceTargetInput,
  parseAdminRejectDeviceInput,
  parseAdminReplaceDeviceInput,
} from "../services/admin_device_administration_service";

test("admin target parser rejects malformed document segments", () => {
  assert.throws(() => parseAdminDeviceTargetInput(null));
  assert.throws(() =>
    parseAdminDeviceTargetInput({ userId: "u/x", requestId: "r" }),
  );
});

test("admin rejection requires bounded reason", () => {
  assert.throws(() =>
    parseAdminRejectDeviceInput({
      userId: "u",
      requestId: "r",
      reason: "x",
    }),
  );
  const value = parseAdminRejectDeviceInput({
    userId: "u",
    requestId: "r",
    reason: "security review",
  });
  assert.equal(value.reason, "security review");
});

test("replacement requires explicit old device and reason", () => {
  const value = parseAdminReplaceDeviceInput({
    userId: "u",
    requestId: "r",
    previousDeviceId: "old",
    reason: "owner requested replacement",
  });
  assert.equal(value.previousDeviceId, "old");
});
