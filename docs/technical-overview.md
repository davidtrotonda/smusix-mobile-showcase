# Technical Overview

Smusix is a native mobile project split into two separate codebases:

- iOS native app built with Swift, Xcode, CocoaPods, and a notification content extension
- Android native app built with Gradle, Java/Kotlin, AndroidX, Firebase, media libraries, and local AAR dependencies

The product experience centers on a vertical swipe feed for discovering emerging artists. Each swipe moves the user into another song/video experience, combining music discovery, full-song listening, creator profiles, and social actions.

## Android Codebase

Observed configuration:

- Application ID: `com.smusix.app`
- Version name: `5.1.0`
- Version code: `15`
- Minimum SDK: `24`
- Compile SDK: `35`
- Target SDK: `36`
- Languages: Java and Kotlin
- Build system: Gradle / Android Gradle Plugin

Major Android areas:

- Authentication and account creation
- Swipe-based feed and discovery screens
- Video player and media services
- Upload workers and background jobs
- Chat, comments, notifications, and sharing
- Premium and purchase flows
- Profile, analytics, monetization, and wallet screens
- Local Room database layer
- Firebase Messaging and notification handlers
- Local AAR SDK integrations
- Large-video user flows, including strings and validation for files under 2 GB

## iOS Codebase

Observed configuration:

- Bundle ID: `app.smusix.com`
- Swift version: `5.0`
- Deployment target: iOS `13.0` for the main app
- Notification extension deployment target: iOS `16.2`
- Package manager: CocoaPods
- Workspace-based Xcode project

Major iOS areas:

- App shell and tab bar navigation
- Authentication and account flows
- Media upload/playback
- Firebase services
- Social login/share SDKs
- Notification content extension
- Camera and image/video picker workflows
- Local storage and model layers

## Media And Feed Performance

The app was designed for a fast, media-heavy feed. The implementation combined several techniques that help reduce perceived waiting time:

- Native media playback instead of web views
- Android Media3/ExoPlayer for video playback
- Android `SimpleCache` with an LRU eviction strategy
- Android HTTP proxy video cache with a configured 1 GB cache budget
- Background upload orchestration through Android WorkManager
- Firebase Storage upload path for videos, thumbnails, and GIF previews
- FFmpeg/media tooling for video preparation and compression
- iOS AVPlayer/GSPlayer-based video cells
- Image caching through SDWebImage, Kingfisher, and Fresco

For large uploads, the Android app includes user-facing flows for videos below 2 GB and guidance for 1-2 GB videos, where compression can reduce upload time. Feed playback was treated separately from upload time: browsing was optimized with caching and native players so already available media could feel immediate while heavier upload tasks continued in the background.

## Representative Integrations

- Firebase Auth, Realtime Database, Storage, Messaging, Analytics, Crashlytics
- Facebook Login and sharing
- Google Sign-In
- In-app purchases / billing
- Ads and consent flows
- Media playback and upload tooling
- Image loading and caching libraries
- AR/effects and camera-related SDKs

## Engineering Notes

The project is relaunchable, but it should be treated as a modernization project rather than a simple rebuild. The main work is dependency compatibility, store compliance, backend validation, and full QA on modern iOS and Android devices.
