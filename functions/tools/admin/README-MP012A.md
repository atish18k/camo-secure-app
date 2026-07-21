# CAMO MP-012A — Test Commercial Access Provisioner

Admin-only CLI for temporary CAMO testing while no payment gateway is connected.

- Uses Firebase Admin SDK + Application Default Credentials.
- Not callable from Flutter.
- Not exported as a Firebase Function.
- Restricted to project `camo-b3cab`.
- Live writes require `CAMO_TEST_ACCESS_ONLY`.
- Only test-marked records may be overwritten or revoked.
- Production remains OFF.

Provision:
`node functions/tools/admin/provision-test-commercial-access.cjs --uid "<UID>" --days 30 --device-allowance 3 --confirm CAMO_TEST_ACCESS_ONLY`

Revoke:
`node functions/tools/admin/provision-test-commercial-access.cjs --uid "<UID>" --revoke --confirm CAMO_TEST_ACCESS_ONLY`
