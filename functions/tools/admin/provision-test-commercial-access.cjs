"use strict";

const { applicationDefault, initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");

const PROJECT_ID = "camo-b3cab";
const CONFIRM = "CAMO_TEST_ACCESS_ONLY";

function parse(argv) {
  const o = { uid: "", days: 30, deviceAllowance: 3, dryRun: false, revoke: false, confirm: "" };

  for (let i = 0; i < argv.length; i += 1) {
    const a = argv[i];
    if (a === "--uid") o.uid = argv[++i] || "";
    else if (a === "--days") o.days = Number(argv[++i]);
    else if (a === "--device-allowance") o.deviceAllowance = Number(argv[++i]);
    else if (a === "--confirm") o.confirm = argv[++i] || "";
    else if (a === "--dry-run") o.dryRun = true;
    else if (a === "--revoke") o.revoke = true;
    else throw new Error(`Unknown argument: ${a}`);
  }

  if (!/^[A-Za-z0-9_-]{20,128}$/.test(o.uid)) {
    throw new Error("Valid --uid is required.");
  }
  if (!Number.isInteger(o.days) || o.days < 1 || o.days > 90) {
    throw new Error("--days must be 1..90.");
  }
  if (!Number.isInteger(o.deviceAllowance) || o.deviceAllowance < 1 || o.deviceAllowance > 10) {
    throw new Error("--device-allowance must be 1..10.");
  }
  if (!o.dryRun && o.confirm !== CONFIRM) {
    throw new Error(`Live execution requires --confirm ${CONFIRM}.`);
  }
  return o;
}

function documentFor(o) {
  const now = new Date();
  const expiry = new Date(now.getTime() + o.days * 86400000);

  return {
    schemaVersion: 2,
    userId: o.uid,
    planId: "camo_monthly_inr_199",
    monthlyPriceInr: 199,
    licenseStatus: "active",
    subscriptionStatus: "active",
    billingState: "paid",
    deviceAllowance: o.deviceAllowance,
    grantedEntitlements: ["baseEncoding", "baseDecoding"],
    expiresAt: expiry.toISOString(),
    environment: "test",
    testAccess: true,
    paymentProvider: "none",
    provisionedBy: "mp-012a-admin-cli",
    provisionedAt: now.toISOString()
  };
}

async function main() {
  const o = parse(process.argv.slice(2));
  const selectedProject = process.env.GOOGLE_CLOUD_PROJECT || PROJECT_ID;

  if (selectedProject !== PROJECT_ID) {
    throw new Error(`Refusing project '${selectedProject}'. Expected '${PROJECT_ID}'.`);
  }

  const path = `users/${o.uid}/commercialAccessV2/current`;

  if (o.revoke) {
    console.log(JSON.stringify({ action: "revoke", projectId: PROJECT_ID, path, dryRun: o.dryRun }, null, 2));
    if (o.dryRun) return;

    initializeApp({ credential: applicationDefault(), projectId: PROJECT_ID });
    const ref = getFirestore().doc(path);
    const existing = await ref.get();

    if (!existing.exists) {
      console.log("[INFO] No test access document exists.");
      return;
    }

    const data = existing.data() || {};
    if (data.testAccess !== true || data.environment !== "test") {
      throw new Error("Refusing to delete a document not explicitly marked as test access.");
    }

    await ref.delete();
    console.log("[PASS] Test commercial access revoked.");
    return;
  }

  const data = documentFor(o);
  console.log(JSON.stringify({ action: "provision", projectId: PROJECT_ID, path, dryRun: o.dryRun, data }, null, 2));
  if (o.dryRun) return;

  initializeApp({ credential: applicationDefault(), projectId: PROJECT_ID });
  const db = getFirestore();
  const ref = db.doc(path);
  const existing = await ref.get();

  if (existing.exists) {
    const old = existing.data() || {};
    if (old.testAccess !== true || old.environment !== "test") {
      throw new Error("Refusing to overwrite a document not explicitly marked as test access.");
    }
  }

  await ref.set({ ...data, serverWrittenAt: FieldValue.serverTimestamp() }, { merge: false });

  const verify = await ref.get();
  const written = verify.data() || {};
  const valid =
    verify.exists &&
    written.schemaVersion === 2 &&
    written.userId === o.uid &&
    written.planId === "camo_monthly_inr_199" &&
    written.monthlyPriceInr === 199 &&
    written.licenseStatus === "active" &&
    written.subscriptionStatus === "active" &&
    written.billingState === "paid" &&
    Number.isInteger(written.deviceAllowance) &&
    written.deviceAllowance >= 1 &&
    Array.isArray(written.grantedEntitlements) &&
    written.grantedEntitlements.includes("baseEncoding") &&
    written.grantedEntitlements.includes("baseDecoding") &&
    Date.parse(written.expiresAt) > Date.now() &&
    written.environment === "test" &&
    written.testAccess === true;

  if (!valid) throw new Error("Post-write verification failed.");

  console.log("[PASS] MP-012A test access provisioned and verified.");
}

main().catch((error) => {
  console.error(`[FAIL] ${error instanceof Error ? error.message : String(error)}`);
  process.exitCode = 1;
});
