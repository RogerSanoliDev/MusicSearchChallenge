# MusicSearchChallenge

## Overview

The app includes:

- Splash screen
- Song search screen
- Song details / player screen
- More options bottom sheet
- Album screen

Core capabilities:

- Search songs from the iTunes API
- Paginated search results in the UI
- Album lookup
- Audio preview playback
- Recent played songs on the home screen
- Offline-first cached search results
- Local caching for artwork and audio previews
- Localized user-facing strings
- Unit and snapshot tests


## Project Setup

1. Clone the repository.
2. Open [MusicSearchChallenge.xcodeproj](MusicSearchChallenge/MusicSearchChallenge.xcodeproj).
3. Select the `MusicSearchChallenge` scheme.
4. Run the app on an iPhone simulator.

Swift Package dependencies are local for the two internal packages, and Xcode will automatically resolve the external test dependency used for snapshot testing.


## Project Structure

High-level structure:

```
MusicSearchChallenge/
├── README.md
└── MusicSearchChallenge/
    ├── MusicSearchChallenge/
    │   ├── App/
    │   ├── Features/
    │   ├── Models/
    │   ├── Resources/
    │   └── Services/
    ├── MusicSearchChallengeTests/
    └── Packages/
        ├── Networking/
        └── SongPlayer/
```


## Architecture

The app uses a practical MVVM structure with clear separation between UI, business logic, data access, and reusable infrastructure.

### App Layer

Main entry points:

- [MusicSearchChallengeApp.swift](MusicSearchChallenge/MusicSearchChallenge/App/MusicSearchChallengeApp.swift)
- [RootView.swift](MusicSearchChallenge/MusicSearchChallenge/App/RootView.swift)
- [AppCoordinator.swift](MusicSearchChallenge/MusicSearchChallenge/App/AppCoordinator.swift)

The coordinator centralizes navigation between:

- search
- player
- album
- more options bottom sheet

### Presentation Layer

Feature folders live under [Features](MusicSearchChallenge/MusicSearchChallenge/Features):

- `SongSearch`
- `SongPlayer`
- `Album`
- `MoreOptionsActionsheet`
- shared `Components`

Each feature keeps its SwiftUI view and its ViewModel close together where applicable.

### Domain / Service Layer

The main application service is [SearchService.swift](MusicSearchChallenge/MusicSearchChallenge/Services/SearchService.swift).

It coordinates:

- remote search requests
- album lookup
- recent played persistence
- search cache reads
- delayed cache persistence

The Service is composed by APISearchRepository and LocalStorageRepository, prioritizing cached data for an offline first experience. 

### Data Layer

Repositories abstract the concrete data sources:

- [APISearchRepository.swift](MusicSearchChallenge/MusicSearchChallenge/Services/Repositories/APISearch/APISearchRepository.swift)
- [LocalStorageRepository.swift](MusicSearchChallenge/MusicSearchChallenge/Services/Repositories/LocalStorage/LocalStorageRepository.swift)

### Concurrency

Swift concurrency is used across the project with:

- `async/await` service and repository APIs
- actor-based request deduplication in the networking layer
- task-based debounced searching
- background cache persistence


## Dependencies

### Local Packages

#### `Networking`

Located in [Packages/Networking](MusicSearchChallenge/Packages/Networking).

Responsibilities:

- endpoint building
- generic API client abstraction
- retry strategy
- in-flight request deduplication
- local file cache for images and audio

Key types:

- [APIClient.swift](MusicSearchChallenge/Packages/Networking/Sources/Networking/APIClient.swift)
- [Endpoint.swift](MusicSearchChallenge/Packages/Networking/Sources/Networking/Endpoint.swift)
- [RequestRetryStrategy.swift](MusicSearchChallenge/Packages/Networking/Sources/Networking/RequestRetryStrategy.swift)
- [InFlightRequestDeduplicator.swift](MusicSearchChallenge/Packages/Networking/Sources/Networking/InFlightRequestDeduplicator.swift)
- [LocalFileCache.swift](MusicSearchChallenge/Packages/Networking/Sources/Networking/LocalFileCache.swift)

#### `SongPlayer`

Located in [Packages/SongPlayer](MusicSearchChallenge/Packages/SongPlayer).

Responsibilities:

- reusable player screen
- playback state and controls
- `AVPlayer` wrapper and playback controller
- timeline / seeking UI
- reusable song model shared with the app target

Key types:

- [SongPlayerView.swift](MusicSearchChallenge/Packages/SongPlayer/Sources/SongPlayer/View/SongPlayerView.swift)
- [SongPlayerViewModel.swift](MusicSearchChallenge/Packages/SongPlayer/Sources/SongPlayer/View/SongPlayerViewModel.swift)
- [AVSongPlaybackController.swift](MusicSearchChallenge/Packages/SongPlayer/Sources/SongPlayer/PlaybackController/AVSongPlaybackController.swift)
- [Song.swift](MusicSearchChallenge/Packages/SongPlayer/Sources/SongPlayer/Song.swift)

### External Dependency

- [pointfreeco/swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing) for UI snapshot tests


## Features

### Search

The home screen supports:

- search field with debounce
- loading, error, empty, and success states
- pull to refresh
- pagination trigger when reaching the bottom of the list

Main files:

- [SongSearchView.swift](MusicSearchChallenge/MusicSearchChallenge/Features/SongSearch/SongSearchView.swift)
- [SongSearchViewModel.swift](MusicSearchChallenge/MusicSearchChallenge/Features/SongSearch/SongSearchViewModel.swift)

### Recently Played

The home screen also shows the most recently played songs when there is no active search query.

Behavior:

- recent songs are stored locally with SwiftData
- they are displayed in recency order
- songs can be removed with swipe-to-delete

### Album View

The album screen loads tracks for a collection and supports:

- loading state
- success state
- empty state
- error state

Main files:

- [AlbumView.swift](MusicSearchChallenge/MusicSearchChallenge/Features/Album/AlbumView.swift)
- [AlbumViewModel.swift](MusicSearchChallenge/MusicSearchChallenge/Features/Album/AlbumViewModel.swift)

### Player

The player experience supports:

- play / pause
- previous / next track
- repeat toggle
- playback timeline
- seeking with slider
- local audio file preference when available

The app wraps the reusable `SongPlayer` package through:

- [SongPlayerContainerView.swift](MusicSearchChallenge/MusicSearchChallenge/Features/SongPlayer/SongPlayerContainerView.swift)
- [SongPlayerContainerViewModel.swift](MusicSearchChallenge/MusicSearchChallenge/Features/SongPlayer/SongPlayerContainerViewModel.swift)

### Offline-First Caching

There are two caching strategies in the project:

1. Search result persistence with SwiftData for offline-first queries and recent played items.
2. File caching for artwork and audio previews through the shared local file cache in `Networking`.

## Localization and Accessibility

The app includes localized strings in:

- English
- Portuguese (Brazil)
- Simplified Chinese

Localization resources exist both in the app target and in the `SongPlayer` package for player-specific strings.

Accessibility work includes:

- labeled controls
- accessible loading and empty states
- VoiceOver labels for song rows
- decorative artwork hidden from accessibility where appropriate


## Notes on Pagination

The UI supports paginated loading, but the iTunes Search API behavior around `offset` is not reliable in practice. The current implementation documents that limitation and works around it by increasing the `limit` and deduplicating by `trackID` inside [SearchService.swift](MusicSearchChallenge/MusicSearchChallenge/Services/SearchService.swift).

## Future Improvements

Possible next steps to improve scalability:

- Integrate the project with Tuist to generate the xcodeproj locally and reduce pull request conflicts
- Create a Fastfile for CI/CD integration
- Integrate SwiftLint to enforce the team’s code style guidelines
- Create .xcconfig files for environment customization, such as BaseURL
- Introduce use case abstractions, such as SearchSongsUseCase and GetRecentlyPlayedUseCase
- Move reusable UI components into a DesignSystem package
- Create a compact floating player view to be displayed when a song is playing outside SongPlayerView
