import {
  Firestore,
} from "firebase-admin/firestore";

import {
  CamoCloudKmsClient,
} from "../kms/camo_cloud_kms_client";
import {
  FirebaseAdminCamoAuthorizationDocumentReader,
} from "../infrastructure/firebase_admin_authorization_document_reader";
import {
  FirestoreCamoAuthorizationReplayStore,
} from "../replay/firestore_authorization_replay_store";
import {
  camoProductionSecurityConfig,
} from "../config/production_security_config";
import {
  DefaultCamoCrc32cCalculator,
} from "../kms/camo_crc32c_calculator";
import {
  createCamoCloudKmsProductionAdapters,
} from "../kms/cloud_kms_production_adapter_factory";
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
  FirestoreCamoMessageLifecycleAuthorizationPort,
} from "../validators/firestore_message_lifecycle_authorization_port";

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
  readonly kmsClient?: CamoCloudKmsClient;
}

export function createCamoProductionServerAuthorizationOrchestrator(
  options: CamoProductionServerAuthorizationFactoryOptions,
): CamoServerAuthorizationOrchestrator {
  const clock = options.clock ?? (() => new Date());

  const kmsAdapters =
    createCamoCloudKmsProductionAdapters({
      keyVersionName:
        camoProductionSecurityConfig.kmsKeyVersionName,
      crc32c:
        new DefaultCamoCrc32cCalculator(),
      client: options.kmsClient,
    });

  const reader =
    new FirebaseAdminCamoAuthorizationDocumentReader(
      options.firestore,
    );

  return new CamoServerAuthorizationOrchestrator({
    userPort: new FirestoreCamoUserAuthorizationPort(reader),
    devicePort: new FirestoreCamoDeviceAuthorizationPort(reader),
    pairPort: new FirestoreCamoPairAuthorizationPort(reader),
    messageLifecyclePort:
      new FirestoreCamoMessageLifecycleAuthorizationPort(
        reader,
        clock,
      ),
    policyPort: new FirestoreCamoPolicyAuthorizationPort(reader),
    riskPort: new FirestoreCamoRiskAuthorizationPort(reader),
    entitlementPort:
      new FirestoreCamoEntitlementAuthorizationPort(
        reader,
        clock,
      ),
    kmsPort:
      kmsAdapters.keyAuthorizationService,
    replayStore: new FirestoreCamoAuthorizationReplayStore(
      options.firestore,
      "enterpriseAuthorizationConsumptions",
      clock,
    ),
    signer: kmsAdapters.signer,
    idGenerator: options.idGenerator,
    clock,
  });
}