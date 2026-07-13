import {
  CamoCrc32cCalculator,
} from "./cloud_kms_authorization_response_signer";

const reversedCastagnoliPolynomial = 0x82f63b78;

function createCrc32cTable(): Readonly<Uint32Array> {
  const table = new Uint32Array(256);

  for (let index = 0; index < 256; index += 1) {
    let value = index;

    for (let bit = 0; bit < 8; bit += 1) {
      value =
        (value & 1) === 1
          ? (value >>> 1) ^ reversedCastagnoliPolynomial
          : value >>> 1;
    }

    table[index] = value >>> 0;
  }

  return table;
}

const crc32cTable = createCrc32cTable();

export class DefaultCamoCrc32cCalculator
  implements CamoCrc32cCalculator {
  calculate(value: Uint8Array): string {
    let crc = 0xffffffff;

    for (const byte of value) {
      const tableIndex = (crc ^ byte) & 0xff;

      crc =
        (crc32cTable[tableIndex] ^
          (crc >>> 8)) >>>
        0;
    }

    return ((crc ^ 0xffffffff) >>> 0).toString(10);
  }

  verify(
    value: Uint8Array,
    expectedCrc32c: string,
  ): boolean {
    const normalized = expectedCrc32c.trim();

    if (!/^[0-9]+$/.test(normalized)) {
      return false;
    }

    try {
      const expected = BigInt(normalized);

      if (
        expected < 0n ||
        expected > 4294967295n
      ) {
        return false;
      }

      return this.calculate(value) === expected.toString(10);
    } catch {
      return false;
    }
  }
}