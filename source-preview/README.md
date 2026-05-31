# Source Preview

This folder contains sanitized source-code excerpts from the native Smusix mobile apps.

The goal is to make the engineering work visible in the public portfolio repository while keeping the production repositories private.

## Included Areas

### Android

- Background video upload with WorkManager and Firebase Storage
- Multipart upload API layer
- Upload progress handling
- FFmpeg/media processing helpers
- Language selection and locale wrapping
- Genre/subgenre selection flows
- Premium and purchase screens
- Localized Android string resources

### iOS

- App launch setup, Firebase, push notifications, and device-language defaults
- Device-language onboarding and localized legal/privacy flows
- In-app language switching
- Music feed controller and media cells
- Video upload metadata flow
- Moya/Alamofire network layer
- Localized iOS string resources

## Sanitization Notes

The preview intentionally excludes or replaces:

- Firebase plist/json files
- API keys and server tokens
- Signing credentials
- Keystores and certificates
- Vendor SDK binaries
- Generated build output
- Local machine/user state

Some identifiers and private values have been replaced with placeholders for public display.
