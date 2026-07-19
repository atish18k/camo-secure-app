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
import {FirestoreCamoMessagePolicyStoreV2} from "../infrastructure/firestore_camo_message_policy_store_v2";
import {CamoMessagePolicyV2LifecycleService} from "./message_policy_v2_lifecycle_service";
import {CamoServerAuthorizer} from "./authorized_message_policy_service";
import {AuthorizedMessagePolicyV2Service} from "./authorized_message_policy_v2_service";
import {
  FirestoreCamoDeviceAuthorizationPort,
} from "../validators/firestore_device_authorization_port";
import {
  FirestoreCamoEntitlementAuthorizationPortV2,
} from "../validators/firestore_entitlement_authorization_port_v2";
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
  readonly messagePolicyMutationEnabled?: boolean;
}

export function createCamoProductionServerAuthorizationOrchestrator(
  options: CamoProductionServerAuthorizationFactoryOptions,
): CamoServerAuthorizer {
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

  const orchestrator = new CamoServerAuthorizationOrchestrator({
    userPort: new FirestoreCamoUserAuthorizationPort(reader),
    devicePort: new FirestoreCamoDeviceAuthorizationPort(reader),
    pairPort: new FirestoreCamoPairAuthorizationPort(reader),
    messageLifecyclePort:
      new FirestoreCamoMessageLifecycleAuthorizationPort(
        reader,
        clock,
      ),
    policyPort: new FirestoreCamoPolicyAuthorizationPort(reader),
    riskPort: new FirestoreCamoRiskAuthorizationPort(reader, clock),
    entitlementPort:
      new FirestoreCamoEntitlementAuthorizationPortV2(
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

  if (options.messagePolicyMutationEnabled !== true) return orchestrator;

  return new AuthorizedMessagePolicyV2Service(
    orchestrator,
    new CamoMessagePolicyV2LifecycleService(
      new FirestoreCamoMessagePolicyStoreV2(options.firestore),
      clock,
    ),
    {isMessagePolicyMutationEnabled: () =>
      options.messagePolicyMutationEnabled === true},
  );
}
