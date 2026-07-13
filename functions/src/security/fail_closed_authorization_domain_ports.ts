import {
  CamoDomainDecision,
  CamoServerAuthorizationContext,
} from "../domain/authorization_types";
import {
  CamoDeviceAuthorizationPort,
  CamoEntitlementAuthorizationPort,
  CamoPairAuthorizationPort,
  CamoPolicyAuthorizationPort,
  CamoRiskAuthorizationPort,
  CamoUserAuthorizationPort,
} from "../domain/authorization_ports";

function denied(reasonCode: string): CamoDomainDecision {
  return Object.freeze({
    allowed: false,
    reasonCode,
  });
}

export class FailClosedCamoUserAuthorizationPort
  implements CamoUserAuthorizationPort {
  async validateUser(
    context: CamoServerAuthorizationContext,
  ): Promise<CamoDomainDecision> {
    void context;
    return denied("production_user_authorization_unavailable");
  }
}

export class FailClosedCamoDeviceAuthorizationPort
  implements CamoDeviceAuthorizationPort {
  async validateDevice(
    context: CamoServerAuthorizationContext,
  ): Promise<CamoDomainDecision> {
    void context;
    return denied("production_device_authorization_unavailable");
  }
}

export class FailClosedCamoPairAuthorizationPort
  implements CamoPairAuthorizationPort {
  async validatePair(
    context: CamoServerAuthorizationContext,
  ): Promise<CamoDomainDecision> {
    void context;
    return denied("production_pair_authorization_unavailable");
  }
}

export class FailClosedCamoPolicyAuthorizationPort
  implements CamoPolicyAuthorizationPort {
  async evaluatePolicy(
    context: CamoServerAuthorizationContext,
  ): Promise<CamoDomainDecision> {
    void context;
    return denied("production_policy_authorization_unavailable");
  }
}

export class FailClosedCamoRiskAuthorizationPort
  implements CamoRiskAuthorizationPort {
  async evaluateRisk(
    context: CamoServerAuthorizationContext,
  ): Promise<CamoDomainDecision> {
    void context;
    return denied("production_risk_authorization_unavailable");
  }
}

export class FailClosedCamoEntitlementAuthorizationPort
  implements CamoEntitlementAuthorizationPort {
  async validateEntitlements(
    context: CamoServerAuthorizationContext,
  ): Promise<CamoDomainDecision> {
    void context;
    return denied("production_entitlement_authorization_unavailable");
  }
}