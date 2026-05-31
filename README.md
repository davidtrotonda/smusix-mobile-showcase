# Smusix Mobile

Portfolio case study for **Smusix**, a native iOS and Android music discovery app for emerging artists.

This repository is intentionally a public showcase, not the full production source tree. The complete native projects contain private configuration, signing assets, Firebase files, third-party SDK binaries, and release credentials, so they are kept in a private repository.

## Product Concept

Smusix was designed around a simple idea: discover new artists by swiping through a vertical, TikTok-style feed where every swipe reveals a track you have probably never heard on mainstream platforms.

Instead of short previews only, the app experience was built around listening to complete songs while browsing fast, visual artist content. The goal was to make music discovery feel immediate: swipe, watch, listen, save, share, and keep discovering.

Core product areas:

- Swipe-based music and video discovery
- Full-song listening experience for emerging artists
- Native iOS and Android applications
- Artist profiles, creator tools, and verification flows
- Video and music upload workflows
- Large video handling, including flows for files up to 2 GB
- Likes, comments, sharing, chat, and notifications
- Playlists, favorites, and music search
- Premium, monetization, wallet, billing, and ad integrations
- Firebase-backed authentication, storage, messaging, analytics, and crash reporting

## Engineering Focus

This case study focuses on my mobile engineering work across the Smusix iOS and Android codebases.

Key engineering areas:

- Native Android development with Java, Kotlin, Gradle, Firebase, media playback, billing, ads, and local libraries
- Native iOS development with Swift, Xcode, CocoaPods, Firebase, social login, media SDKs, and notification extensions
- Product customization, app branding, and release preparation
- Third-party SDK integration and dependency management
- Media upload, background processing, playback, and cache-heavy feed performance
- Store-readiness review for Google Play and App Store requirements
- Technical triage for relaunch feasibility

## Performance Highlights

Smusix was built for a media-heavy experience where browsing needed to feel instant even while handling large audio/video files.

Notable implementation areas:

- Vertical feed playback using native media players on both platforms
- Android Media3/ExoPlayer integration for modern playback
- Android proxy video cache and LRU media cache to reduce repeat network loading
- Firebase Storage upload flow for video, thumbnails, and GIF previews
- WorkManager-based background upload flow on Android
- FFmpeg/media processing support for preparing and compressing video assets
- Image caching through libraries such as SDWebImage, Kingfisher, and Fresco
- iOS playback and feed cells built around AVPlayer/GSPlayer-based video components

The result was an app architecture designed to make swiping feel immediate: the interface could move quickly while media assets were cached, reused, uploaded in the background, and prepared for playback.

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
