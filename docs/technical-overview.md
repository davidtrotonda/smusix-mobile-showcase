# Technical Overview

Smusix is a native mobile project split into two separate codebases:

- iOS native app built with Swift, Xcode, CocoaPods, and a notification content extension
- Android native app built with Gradle, Java/Kotlin, AndroidX, Firebase, media libraries, and local AAR dependencies

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
- Feed/discovery screens
- Video player and media services
- Upload workers and background jobs
- Chat, comments, notifications, and sharing
- Premium and purchase flows
- Profile, analytics, monetization, and wallet screens
- Local Room database layer
- Firebase Messaging and notification handlers
- Local AAR SDK integrations

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
