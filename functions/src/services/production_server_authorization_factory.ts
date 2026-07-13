import {
  Firestore,
} from "firebase-admin/firestore";

import {
  FirebaseAdminCamoAuthorizationDocumentReader,
} from "../infrastructure/firebase_admin_authorization_document_reader";
import {
  FirestoreCamoAuthorizationReplayStore,
} from "../replay/firestore_authorization_replay_store";
import {
  FailClosedCamoAuthorizationResponseSigner,
} from "../security/fail_closed_authorization_response_signer";
import {
  FailClosedCamoKmsAuthorizationService,
} from "../security/fail_closed_kms_authorization_service";
import {
  CamoServerAuthorizationOrchestrator,
} from "./server_authorization_orchestrator";
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

export interface CamoProductionServerAuthorizationFactoryOptions {
  readonly firestore: Firestore;
  readonly idGenerator: () => string;
  readonly clock?: () => Date;
}

export function createCamoProductionServerAuthorizationOrchestrator(
  options: CamoProductionServerAuthorizationFactoryOptions,
): CamoServerAuthorizationOrchestrator {
  const clock = options.clock ?? (() => new Date());

  const reader =
    new FirebaseAdminCamoAuthorizationDocumentReader(
      options.firestore,
    );

  return new CamoServerAuthorizationOrchestrator({
    userPort: new FirestoreCamoUserAuthorizationPort(reader),
    devicePort: new FirestoreCamoDeviceAuthorizationPort(reader),
    pairPort: new FirestoreCamoPairAuthorizationPort(reader),
    policyPort: new FirestoreCamoPolicyAuthorizationPort(reader),
    riskPort: new FirestoreCamoRiskAuthorizationPort(reader),
    entitlementPort:
      new FirestoreCamoEntitlementAuthorizationPort(
        reader,
        clock,
      ),
    kmsPort: new FailClosedCamoKmsAuthorizationService(),
    replayStore: new FirestoreCamoAuthorizationReplayStore(
      options.firestore,
      "enterpriseAuthorizationConsumptions",
      clock,
    ),
    signer: new FailClosedCamoAuthorizationResponseSigner(),
    idGenerator: options.idGenerator,
    clock,
  });
}