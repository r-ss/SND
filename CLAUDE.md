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
