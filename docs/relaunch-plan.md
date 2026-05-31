# Relaunch Plan

## Phase 1: Build Audit

Goal: determine whether the existing apps compile on current toolchains.

- Open Android project in current Android Studio
- Run Gradle sync and debug build
- Open iOS workspace in current Xcode
- Run `pod install` and simulator/device build
- Record all blocking compiler, SDK, and signing issues
- Verify Firebase projects and app IDs
- Verify the music discovery feed, full-song playback, video cache behavior, and large-upload paths

Estimated effort: 1 to 3 days.

## Phase 2: Core Modernization

Goal: make the apps technically viable for store submission.

- Update high-risk SDKs
- Remove deprecated or unavailable SDK integrations
- Replace broken dependencies where necessary
- Verify Android target SDK and native library compatibility
- Verify iOS SDK, privacy manifest, and required-reason API compliance
- Update permissions, privacy labels, and store metadata inputs

Estimated effort: 2 to 4 weeks if backend and accounts are still valid.

## Phase 3: Product QA

Goal: prove that the core user flows still work.

- Login and signup
- Swipe-based discovery feed loading
- Video playback
- Full-song playback
- Video upload
- Large video upload path below 2 GB
- Music/song screens
- Profile editing
- Comments, likes, sharing
- Chat/inbox
- Push notifications
- Premium/purchases
- Ads and consent

Estimated effort: 1 to 3 weeks depending on defects.

## Phase 4: Store Release

Goal: prepare TestFlight and Google Play tracks.

- Create clean release builds
- Configure signing
- Prepare screenshots and store copy
- Fill privacy and data safety forms
- Submit internal testing builds
- Fix review feedback

Estimated effort: 1 to 2 weeks.

## Main Risks

- Backend/API endpoints may be unavailable
- Firebase project ownership may need migration
- Old SDKs may fail modern App Store or Play Store checks
- Media/camera code may break on new OS versions
- Signing credentials may need replacement
- App privacy requirements may require code or metadata changes
