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
