import {
  CamoAuthorizationReplayStore,
  CamoDeviceAuthorizationPort,
  CamoEntitlementAuthorizationPort,
  CamoKmsAuthorizationPort,
  CamoMessageLifecycleAuthorizationPort,
  CamoPairAuthorizationPort,
  CamoPolicyAuthorizationPort,
  CamoRiskAuthorizationPort,
  CamoUserAuthorizationPort,
} from "../domain/authorization_ports";
import {
  CamoAuthorizationResponseSignerV2,
} from "../domain/authorization_ports_v2";
import {
  CamoDomainDecision,
  CamoReplayArtifact,
  CamoServerAuthorizationContext,
} from "../domain/authorization_types";
import {
  CamoAuthorizationExecutionResultV2,
  CamoUnsignedAuthorizationResponseV2,
  camoAuthorizationCanonicalizationVersionV2,
  camoAuthorizationSchemaVersionV2,
  camoServerShareVersionV1,
} from "../domain/authorization_types_v2";
import {
  CamoServerShareGenerator,
} from "../security/server_share_generator";

export interface CamoServerAuthorizerV2 {
  authorize(
    context: CamoServerAuthorizationContext,
  ): Promise<CamoAuthorizationExecutionResultV2>;
}

export interface CamoServerAuthorizationOrchestratorV2Dependencies {
  readonly userPort: CamoUserAuthorizationPort;
  readonly devicePort: CamoDeviceAuthorizationPort;
  readonly pairPort: CamoPairAuthorizationPort;
  readonly messageLifecyclePort: CamoMessageLifecycleAuthorizationPort;
  readonly policyPort: CamoPolicyAuthorizationPort;
  readonly riskPort: CamoRiskAuthorizationPort;
  readonly entitlementPort: CamoEntitlementAuthorizationPort;
  readonly kmsPort: CamoKmsAuthorizationPort;
  readonly replayStore: CamoAuthorizationReplayStore;
  readonly signer: CamoAuthorizationResponseSignerV2;
  readonly serverShareGenerator: CamoServerShareGenerator;
  readonly idGenerator: () => string;
  readonly clock: () => Date;
}

export class CamoServerAuthorizationOrchestratorV2
implements CamoServerAuthorizerV2 {
  constructor(
    private readonly dependencies:
      CamoServerAuthorizationOrchestratorV2Dependencies,
  ) {}

  async authorize(
    context: CamoServerAuthorizationContext,
  ): Promise<CamoAuthorizationExecutionResultV2> {
    if (!this.isValidContext(context)) {
      return this.denied("server_authorization_context_invalid");
    }

    const stages: ReadonlyArray<() => Promise<CamoDomainDecision>> = [
      () => this.dependencies.userPort.validateUser(context),
      () => this.dependencies.devicePort.validateDevice(context),
      () => this.dependencies.pairPort.validatePair(context),
      () => this.dependencies.messageLifecyclePort.validateMessageLifecycle(context),
      () => this.dependencies.policyPort.evaluatePolicy(context),
      () => this.dependencies.riskPort.evaluateRisk(context),
      () => this.dependencies.entitlementPort.validateEntitlements(context),
    ];

    for (const stage of stages) {
      const decision = await stage();
      if (!decision.allowed) {
        return this.denied(
          decision.reasonCode.trim() || "server_authorization_stage_denied",
        );
      }
    }

    const now = this.dependencies.clock();
    const expiresAt = new Date(now.getTime() + 60_000);
    const authorizationId = this.requireGeneratedId();
    const challengeId = this.requireGeneratedId();
    const sessionId = this.requireGeneratedId();
    const artifact: CamoReplayArtifact = Object.freeze({
      authorizationId,
      operationId: context.operationId,
      challengeId,
      userId: context.userId,
      issuedAt: now.toISOString(),
      expiresAt: expiresAt.toISOString(),
    });

    if (!await this.dependencies.replayStore.consume(artifact)) {
      return this.denied("server_replay_protection_denied");
    }

    const kmsDecision =
      await this.dependencies.kmsPort.authorizeKeyRelease(context);
    if (
      !kmsDecision.permitted ||
      kmsDecision.releaseId.trim().length === 0 ||
      kmsDecision.keyReference.trim().length === 0
    ) {
      return this.denied(
        kmsDecision.reasonCode.trim() || "server_kms_denied",
      );
    }

    const serverShare = this.dependencies.serverShareGenerator.generate({
      operationId: context.operationId,
      issuedAt: now,
      authorizationExpiresAt: expiresAt,
    });
    const unsignedResponse: CamoUnsignedAuthorizationResponseV2 =
      Object.freeze({
        schemaVersion: camoAuthorizationSchemaVersionV2,
        canonicalizationVersion:
          camoAuthorizationCanonicalizationVersionV2,
        requestId: context.requestId,
        authorized: true,
        authorizationId,
        operationId: context.operationId,
        challengeId,
        userId: context.userId,
        deviceId: context.deviceId,
        pairId: context.pairId!,
        messageId: context.messageId!,
        payloadDigest: context.payloadDigest,
        keyReleaseId: kmsDecision.releaseId,
        keyReference: kmsDecision.keyReference,
        sessionId,
        serverShareId: serverShare.shareId,
        serverShareVersion: serverShare.version,
        serverShareBase64: serverShare.base64,
        serverShareExpiresAt: serverShare.expiresAt,
        issuedAt: artifact.issuedAt,
        expiresAt: artifact.expiresAt,
        reasonCode: "server_authorization_granted",
      });

    try {
      const signedResponse =
        await this.dependencies.signer.sign(unsignedResponse);
      if (
        signedResponse.schemaVersion !== camoAuthorizationSchemaVersionV2 ||
        signedResponse.canonicalizationVersion !==
          camoAuthorizationCanonicalizationVersionV2 ||
        signedResponse.serverShareVersion !== camoServerShareVersionV1 ||
        signedResponse.requestId.trim() !== context.requestId.trim() ||
        signedResponse.operationId.trim() !== context.operationId.trim() ||
        signedResponse.pairId.trim() !== context.pairId!.trim() ||
        signedResponse.messageId.trim() !== context.messageId!.trim() ||
        signedResponse.payloadDigest.trim() !== context.payloadDigest.trim() ||
        signedResponse.serverShareId.trim() !== serverShare.shareId ||
        signedResponse.serverShareBase64.trim() !== serverShare.base64 ||
        signedResponse.signatureAlgorithm !== "EC_SIGN_P256_SHA256" ||
        signedResponse.signatureEncoding !== "DER_BASE64" ||
        signedResponse.signature.trim().length === 0 ||
        signedResponse.signingKeyId.trim().length === 0
      ) {
        return this.denied("server_signature_invalid");
      }
      return Object.freeze({
        authorized: true,
        reasonCode: "server_authorization_granted",
        signedResponse,
      });
    } catch {
      return this.denied("server_signature_unavailable");
    }
  }

  private denied(reasonCode: string): CamoAuthorizationExecutionResultV2 {
    return Object.freeze({authorized: false, reasonCode});
  }

  private requireGeneratedId(): string {
    const value = this.dependencies.idGenerator().trim();
    if (value.length === 0) {
      throw new Error("server_identifier_generation_failed");
    }
    return value;
  }

  private isValidContext(context: CamoServerAuthorizationContext): boolean {
    return (
      context.requestId.trim().length > 0 &&
      context.operationId.trim().length > 0 &&
      context.userId.trim().length > 0 &&
      context.deviceId.trim().length > 0 &&
      (context.pairId?.trim().length ?? 0) > 0 &&
      (context.messageId?.trim().length ?? 0) > 0 &&
      /^[a-f0-9]{64}$/i.test(context.payloadDigest) &&
      context.requiredEntitlements.length > 0 &&
      (context.operationType === "encode" ||
        context.operationType === "decode")
    );
  }
}