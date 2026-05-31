# Security Notes

The public showcase repository must not contain production secrets or release assets.

Files intentionally excluded from the public repository:

- `google-services.json`
- `GoogleService-Info.plist`
- `local.properties`
- `fabric.properties`
- Android keystores and signing files
- Apple certificates, provisioning profiles, and private keys
- API keys, OAuth secrets, service account files, and tokens
- Generated build output
- Local IDE/user state

If this project is relaunched, production credentials should be rotated or regenerated before release.
