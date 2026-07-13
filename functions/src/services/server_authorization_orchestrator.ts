import {
  CamoAuthorizationReplayStore,
  CamoAuthorizationResponseSigner,
  CamoDeviceAuthorizationPort,
  CamoEntitlementAuthorizationPort,
  CamoKmsAuthorizationPort,
  CamoPairAuthorizationPort,
  CamoPolicyAuthorizationPort,
  CamoRiskAuthorizationPort,
  CamoUserAuthorizationPort,
} from "../domain/authorization_ports";
import {
  CamoAuthorizationExecutionResult,
  CamoDomainDecision,
  CamoReplayArtifact,
  CamoServerAuthorizationContext,
  CamoUnsignedAuthorizationResponse,
} from "../domain/authorization_types";

export interface CamoServerAuthorizationOrchestratorDependencies {
  readonly userPort: CamoUserAuthorizationPort;
  readonly devicePort: CamoDeviceAuthorizationPort;
  readonly pairPort: CamoPairAuthorizationPort;
  readonly policyPort: CamoPolicyAuthorizationPort;
  readonly riskPort: CamoRiskAuthorizationPort;
  readonly entitlementPort: CamoEntitlementAuthorizationPort;
  readonly kmsPort: CamoKmsAuthorizationPort;
  readonly replayStore: CamoAuthorizationReplayStore;
  readonly signer: CamoAuthorizationResponseSigner;
  readonly idGenerator: () => string;
  readonly clock: () => Date;
}

export class CamoServerAuthorizationOrchestrator {
  constructor(
    private readonly dependencies:
      CamoServerAuthorizationOrchestratorDependencies,
  ) {}

  async authorize(
    context: CamoServerAuthorizationContext,
  ): Promise<CamoAuthorizationExecutionResult> {
    if (!this.isValidContext(context)) {
      return this.denied("server_authorization_context_invalid");
    }

    const stages: ReadonlyArray<
      () => Promise<CamoDomainDecision>
    > = [
      () => this.dependencies.userPort.validateUser(context),
      () => this.dependencies.devicePort.validateDevice(context),
      () => this.dependencies.pairPort.validatePair(context),
      () => this.dependencies.policyPort.evaluatePolicy(context),
      () => this.dependencies.riskPort.evaluateRisk(context),
      () =>
        this.dependencies.entitlementPort.validateEntitlements(context),
    ];

    for (const stage of stages) {
      const decision = await stage();

      if (!decision.allowed) {
        return this.denied(
          decision.reasonCode.trim() ||
            "server_authorization_stage_denied",
        );
      }
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

    const consumed = await this.dependencies.replayStore.consume(
      artifact,
    );

    if (!consumed) {
      return this.denied("server_replay_protection_denied");
    }

    const unsignedResponse: CamoUnsignedAuthorizationResponse =
      Object.freeze({
        authorized: true,
        authorizationId,
        operationId: context.operationId,
        challengeId,
        userId: context.userId,
        deviceId: context.deviceId,
        pairId: context.pairId,
        messageId: context.messageId,
        keyReleaseId: kmsDecision.releaseId,
        keyReference: kmsDecision.keyReference,
        sessionId,
        issuedAt: artifact.issuedAt,
        expiresAt: artifact.expiresAt,
        reasonCode: "server_authorization_granted",
      });

    try {
      const signedResponse =
        await this.dependencies.signer.sign(unsignedResponse);

      if (
        signedResponse.signature.trim().length === 0 ||
        signedResponse.signingKeyId.trim().length === 0 ||
        signedResponse.signatureAlgorithm.trim().length === 0
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

  private denied(reasonCode: string): CamoAuthorizationExecutionResult {
    return Object.freeze({
      authorized: false,
      reasonCode,
    });
  }

  private requireGeneratedId(): string {
    const value = this.dependencies.idGenerator().trim();

    if (value.length === 0) {
      throw new Error("server_identifier_generation_failed");
    }

    return value;
  }

  private isValidContext(
    context: CamoServerAuthorizationContext,
  ): boolean {
    return (
      context.requestId.trim().length > 0 &&
      context.operationId.trim().length > 0 &&
      context.userId.trim().length > 0 &&
      context.deviceId.trim().length > 0 &&
      context.requiredEntitlements.length > 0 &&
      (context.operationType === "encode" ||
        context.operationType === "decode") &&
      (context.operationType !== "decode" ||
        (context.messageId?.trim().length ?? 0) > 0)
    );
  }
}