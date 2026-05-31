# Smusix Mobile

Portfolio case study for **Smusix**, a social music and short-video mobile app built for iOS and Android.

This repository is intentionally a public showcase, not the full production source tree. The complete native projects contain private configuration, signing assets, Firebase files, third-party SDK binaries, and release credentials, so they are kept in a private repository.

## Product Scope

Smusix was designed as a mobile-first music and video platform with creator/social features:

- Native iOS and Android applications
- User authentication and account flows
- Home feed and video discovery
- Short-video playback and upload workflows
- Music/song related screens and playlists
- Comments, likes, notifications, and sharing
- Chat and inbox functionality
- Creator/profile screens and analytics areas
- Premium, monetization, billing, and ad integrations
- Firebase-backed services and push notifications
- Camera, media processing, filters, and AR/effects integrations

## My Role

I worked on the mobile app implementation, integration, maintenance, and release-readiness of the Smusix iOS and Android codebases.

Key areas included:

- Native Android development with Java, Kotlin, Gradle, Firebase, media playback, billing, ads, and local libraries
- Native iOS development with Swift, Xcode, CocoaPods, Firebase, social login, media SDKs, and notification extensions
- Product customization and app branding
- Third-party SDK integration and dependency management
- Store-readiness review for Google Play and App Store requirements
- Technical triage for relaunch feasibility

## Tech Stack

| Platform | Main Technologies |
| --- | --- |
| Android | Kotlin, Java, Gradle, AndroidX, Firebase, Room, WorkManager, ExoPlayer/Media3, Billing, Ads, Lottie |
| iOS | Swift, Xcode, CocoaPods, Firebase, Alamofire/Moya, RealmSwift, SDWebImage/Kingfisher, notification extensions |
| Media | Camera, video upload, video playback, FFmpeg/media processing, AR/effects SDKs |
| Backend/Services | Firebase Auth, Realtime Database, Storage, Messaging, Crashlytics, Analytics |

## Repository Contents

```text
assets/
  app-brand.png
  logo-estirado.jpg
  logo-redondo.png
docs/
  technical-overview.md
  relaunch-plan.md
  security-notes.md
```

## Why The Full Source Is Private

The production repositories include credentials and app-specific files that should never be published publicly, including:

- Firebase configuration files
- Android signing/keystore material
- Apple/iOS app configuration files
- Local developer machine configuration
- Vendor SDK binaries and licensed assets

For public review, this repository focuses on the product, architecture, responsibilities, and relaunch work rather than exposing sensitive files.

## Status

Current state: archived/relaunch evaluation.

The next technical step is a full build audit on both native projects, followed by dependency updates, privacy compliance review, backend verification, and store submission preparation.
