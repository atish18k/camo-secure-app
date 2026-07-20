import {
  randomBytes,
  randomUUID,
} from "node:crypto";

import {
  CamoGeneratedServerShareV1,
  camoServerShareByteLength,
  camoServerShareVersionV1,
} from "../domain/authorization_types_v2";

export interface CamoServerShareGenerator {
  generate(input: {
    readonly operationId: string;
    readonly issuedAt: Date;
    readonly authorizationExpiresAt: Date;
  }): CamoGeneratedServerShareV1;
}

export class NodeCryptoCamoServerShareGenerator
implements CamoServerShareGenerator {
  generate(input: {
    readonly operationId: string;
    readonly issuedAt: Date;
    readonly authorizationExpiresAt: Date;
  }): CamoGeneratedServerShareV1 {
    const operationId = input.operationId.trim();
    const issuedAtMilliseconds = input.issuedAt.getTime();
    const expiresAtMilliseconds = input.authorizationExpiresAt.getTime();

    if (operationId.length === 0) {
      throw new Error("server_share_operation_id_required");
    }

    if (
      !Number.isFinite(issuedAtMilliseconds) ||
      !Number.isFinite(expiresAtMilliseconds) ||
      expiresAtMilliseconds <= issuedAtMilliseconds
    ) {
      throw new Error("server_share_expiry_invalid");
    }

    const bytes = Uint8Array.from(
      randomBytes(camoServerShareByteLength),
    );

    if (bytes.length !== camoServerShareByteLength) {
      throw new Error("server_share_length_invalid");
    }

    return Object.freeze({
      shareId: randomUUID(),
      operationId,
      version: camoServerShareVersionV1,
      bytes,
      base64: Buffer.from(bytes).toString("base64"),
      expiresAt: input.authorizationExpiresAt.toISOString(),
    });
  }
}