//
//  Playlist.swift
//  SND
//
//  Created by Alex Antipov on 03.03.2023.
//

import Foundation

struct Playlist: Hashable, Identifiable {
    var id: String = UUID().uuidString
    var paths: [URL]
}

// PlaylistTab model for multiple playlists feature
struct PlaylistTab: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var tracks: [Track]
    var isActive: Bool
    
    init(name: String, tracks: [Track] = [], isActive: Bool = false) {
        self.id = UUID().uuidString
        self.name = name
        self.tracks = tracks
        self.isActive = isActive
    }
    
    var totalDuration: TimeInterval {
        tracks.compactMap { $0.metadata.duration }.reduce(0, +)
    }
    
    var formattedTotalDuration: String {
        let totalSeconds = Int(totalDuration)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

// MARK: Mocked Data
extension Playlist {
    struct Mocked {
        let playlist = Playlist(paths: [
            URL(string: "/Users/user/4.mp3")!,
            URL(string: "/Users/user/1.mp3")!,
            URL(string: "/Users/user/3.mp3")!,
            URL(string: "/Users/user/14.mp3")!,
            URL(string: "/Users/user/2.mp3")!,
            URL(string: "/Users/user/100.mp3")!
        ])
    }
    
    static var mocked: Mocked {
        Mocked()
    }
}
