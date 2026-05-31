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

## Feature Set

### Discovery Experience

- Vertical swipe feed inspired by the speed and familiarity of short-form video apps
- Full-song discovery instead of limiting users to short previews
- Music-first browsing designed to surface artists users had not heard on mainstream platforms
- Feed filters for language, genre, and subgenre discovery
- Artist profile pages with music, videos, rankings, and fan interaction

### Internationalization

- Device-language detection on app launch
- Interface localization across 6 languages: English, Spanish, German, Italian, French, and Portuguese
- Music discovery flows by language, so users could browse songs in their preferred language
- Language-specific genre selection during upload and discovery

### Catalog And Taxonomy

- Music catalog scaled to 20,000+ songs
- Catalog organized around approximately 50 genres and 180 subgenres across supported languages
- Genre/subgenre selection for uploads so new music could be routed into the right discovery surfaces
- Weekly trend areas and Top 100 mechanics to keep discovery fresh

### Artist Verification And Uploads

- Artist verification flow before music upload access
- Verification request screens with identity/context checks
- Upload workflows for songs, videos, thumbnails, and preview assets
- Large-video upload support, including user-facing flows for files up to 2 GB
- Background upload handling so users could continue using the app while media was processed

### Playlists And Weekly Curation

- Auto-updating playlists based on weekly trends
- Fresh playlist content surfaced every week from the best-performing songs
- User playlists and favorites
- Offline downloads for songs and playlists
- Top 100 and fan ranking mechanics to highlight rising artists

### Premium, Ads, And Artist Promotion

- Premium subscription flows
- Ad removal for premium users
- Offline listening and unlimited playlist/song downloads for premium users
- Artist promotion panel for boosting songs from inside the app
- In-app campaign setup for paid promotion and extra visibility
- Artist monetization through Smix coins, digital music sales, and promoted placements

## Product Traction

- Featured in public press as a Spanish app for discovering emerging artists
- Reported Top 10 ranking in Google Play Music and Top 100 ranking in App Store during its early launch period
- Google Play listing showed 10K+ installs and positioned Smusix around free music discovery, weekly trend playlists, offline listening, and artist support

Press references:

- [20 Minutos: Existe un 'Spotify español'](https://www.20minutos.es/tecnologia/fabricantes/existe-un-spotify-espanol-es-gratis-te-permite-descubrir-nueva-musica-artistas-emergentes_6242805_0.html)
- [Mallorca Hora: Smusix, la app española que revoluciona la música emergente](https://mallorcahora.com/noticias/tecnologia-y-videojuegos/2025/09/13/smusix-la-app-espanola-que-revoluciona-la-musica-emergente/)
- [Smusix website](https://smusix.com/es/)

## Engineering Focus

This case study focuses on my mobile engineering work across the Smusix iOS and Android codebases.

Key engineering areas:

- Native Android development with Java, Kotlin, Gradle, Firebase, media playback, billing, ads, and local libraries
- Native iOS development with Swift, Xcode, CocoaPods, Firebase, social login, media SDKs, and notification extensions
- Product customization, app branding, and release preparation
- Third-party SDK integration and dependency management
- Media upload, background processing, playback, and cache-heavy feed performance
- Multilingual app flows, language-based music discovery, and genre/subgenre routing
- Artist verification, premium subscriptions, and in-app song promotion flows
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
