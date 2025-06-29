# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SND is a macOS audio player application inspired by foobar2000, built with Swift 5.0 and SwiftUI. The application follows an MVVM-style architecture and uses AVFoundation for audio playback.

## Essential Commands

### Building and Testing
```bash
# Build the project
xcodebuild -project SND.xcodeproj -scheme SND build

# Run tests
xcodebuild -project SND.xcodeproj -scheme SNDTests test

# Clean build artifacts
xcodebuild -project SND.xcodeproj clean

# Run a specific test
xcodebuild -project SND.xcodeproj -scheme SNDTests test-only:SNDTests/SNDTests/testExample
```

### Development in Xcode
- Open `SND.xcodeproj` in Xcode
- Use Cmd+R to run the app
- Use Cmd+U to run all tests
- Use Cmd+B to build without running

## Architecture Overview

### Core Services (Singletons)
- **SNDPlayer** (`Services/SNDPlayer.swift`): Central audio playback service using AVAudioPlayer. Manages play/pause, volume, progress, and track transitions.
- **SNDPlaylist** (`Services/SNDPlaylist.swift`): Manages the current playlist, track selection, and navigation (next/previous).

### Data Flow
1. User drops audio files → `ContentView` handles drop → `SNDPlaylist.append()`
2. Track selection → `SNDPlaylist.selectTrack()` → `SNDPlayer.play(track:)`
3. Playback updates → Timer publishes progress → UI updates via `@Published` properties

### Key UI Patterns
- All views use `@ObservedObject` to observe `SNDPlayer.shared` and `SNDPlaylist.shared`
- Progress updates use a 0.1-second timer for smooth UI updates
- File drops are handled via `.onDrop()` modifier with `public.file-url` UTType

### App Capabilities
- App Sandbox enabled with read-only file access
- Supports mp3 and flac formats via drag & drop
- Keyboard shortcuts: Space for play/pause, Backspace for removing tracks

## Important Implementation Details

### Audio Handling
- The app uses AVAudioPlayer (not AVPlayer) for simplicity
- Audio session configuration happens in `SNDPlayer.init()`
- Progress tracking uses `player.currentTime / player.duration`

### Playlist Management
- Tracks maintain their original file URLs
- Playlist state is not persisted (TODO item)
- Track removal is handled via keyboard events on the list

### Testing Approach
- Use `Playlist.Mocked` for test data
- Tests are in `SNDTests/` directory
- Currently minimal test coverage - expand when adding features

## Active TODOs (from README)
- Add tabs for multiple playlists
- Add duration column to playlist
- Implement playlist persistence
- General UI/UX improvements

## Development Tips
- When modifying audio playback, test with both mp3 and flac files
- Check Console.app for sandboxing issues if file access fails
- Use Xcode's memory graph debugger to verify singleton lifecycles