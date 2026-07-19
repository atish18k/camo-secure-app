function requireSegment(
  value: string,
  segmentName: string,
): string {
  const normalized = value.trim();

  if (
    normalized.length === 0 ||
    normalized.includes("/")
  ) {
    throw new Error(
      `Invalid authorization document segment: ${segmentName}.`,
    );
  }

  return normalized;
}

export const camoAuthorizationDocumentPaths = Object.freeze({
  user(userId: string): string {
    return `users/${requireSegment(userId, "userId")}`;
  },

  device(userId: string, deviceId: string): string {
    return [
      "users",
      requireSegment(userId, "userId"),
      "devices",
      requireSegment(deviceId, "deviceId"),
    ].join("/");
  },

  pairing(pairId: string): string {
    return `pairings/${requireSegment(pairId, "pairId")}`;
  },

  globalPolicy(): string {
    return "enterprisePolicies/global";
  },

  commercialAccess(userId: string): string {
    return [
      "users",
      requireSegment(userId, "userId"),
      "commercialAccess",
      "current",
    ].join("/");
  },
  commercialAccessV2(userId: string): string {
    return [
      "users",
      requireSegment(userId, "userId"),
      "commercialAccessV2",
      "current",
    ].join("/");
  },

  riskDecision(operationId: string): string {
    return [
      "enterpriseRiskDecisions",
      requireSegment(operationId, "operationId"),
    ].join("/");
  },
});
