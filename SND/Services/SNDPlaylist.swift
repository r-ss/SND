//
//  SNDPlaylist.swift
//  SND
//
//  Created by Alex Antipov on 20.02.2023.
//

import Foundation
import AVFoundation

class SNDPlaylist: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    private let playerManager = SNDPlayer.shared
    @Published var tracks: [Track] = []
    
    private let allowed_extensions = ["mp3", "flac", "wav"]
    
    override init() {
        super.init()
        
        NotificationCenter.simple(name: .playbackStarted){
            self.trackStartedPlayingEvent()
        }
        
        NotificationCenter.simple(name: .trackHasEnded){
            self.trackHasEndedEvent()
        }
        
        loadPlaylist() // Load playlist when the app starts
        
    }
    
    // AVAudioPlayerDelegate method, used to catch end of track and play next in a playlist
    @objc public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully: Bool) {
        Notification.fire(name: .trackHasEnded)
    }
    
    
    func trackStartedPlayingEvent(){
        
        // Reset state of all tracks to false
        for (index, _) in self.tracks.enumerated() {
            self.tracks[index].state = false
        }
        
        // Set state of currently playing track to true
        if let idx: Int = self.tracks.firstIndex(where: {$0.id == playerManager.currentTrack?.id}) {
            self.tracks[idx].state = true
        }
    }
    
    func trackHasEndedEvent(){
        if let idx: Int = self.tracks.firstIndex(where: {$0.id == playerManager.currentTrack?.id}) {
            if idx < (self.tracks.count - 1) {
                let nextId = self.tracks[idx + 1].id
                print("Track finished, loading next")
                playTrack(trackId: nextId)
            } else {
                print("Last track in playlist has finished playing")
            }
        }
    }
    
    func addTrack(url: URL) {
        if allowed_extensions.contains(url.pathExtension.lowercased()) {
            var track = Track(path: url, filename: url.lastPathComponent)
            // Create security-scoped bookmark for persistent access
            track.createBookmark()
            DispatchQueue.main.async {
                self.tracks.append(track)
                self.savePlaylist() // Save playlist after adding a track
            }
        }
    }
    
    func addFromPaths(urls: [URL]) {
//                print("addFromPaths", urls)
        
        for url in urls {
            if url.isDirectory {
                print("It's a directory, trying to load file")
                
                let fileManager = FileManager()
                do {
                    var itemsInDir = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
                    // sorting items by file name
                    itemsInDir = itemsInDir.sorted(by: {$0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending})
                    
                    for item in itemsInDir {
                        if allowed_extensions.contains(item.pathExtension.lowercased()) {
                            addTrack(url: item)
                        }
                    }
                } catch {
                    print("failed to read directory – bad permissions, perhaps?")
                }
            } else {
                addTrack(url: url)
            }
            
        }
        
        
    }
    
    func playTrack(trackId: String) {
        if let idx: Int = self.tracks.firstIndex(where: {$0.id == trackId}) {
            playerManager.play(track: tracks[idx])
            
            if playerManager.audioPlayer != nil && playerManager.audioPlayer!.isPlaying {
                playerManager.audioPlayer!.delegate = self
            }
        }
    }
    
    
    func removeTracksFromPlaylist(ids: Set<Track.ID>) -> Void {
        self.tracks = self.tracks.filter { !ids.contains($0.id) }
        self.savePlaylist() // Save playlist after removing a track
    }
    
    
    private func getPlaylistFileURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("playlist.json")
    }
    
    func savePlaylist() {
        // Save playlist to disk
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(self.tracks)
            let url = getPlaylistFileURL()
            try data.write(to: url)
            print("Playlist saved successfully.")
        } catch {
            print("Failed to save playlist:", error)
        }
    }
    
    func loadPlaylist() {
        // Load playlist from disk
        let decoder = JSONDecoder()
        let url = getPlaylistFileURL()
        
        do {
            let data = try Data(contentsOf: url)
            let savedTracks = try decoder.decode([Track].self, from: data)
            self.tracks = savedTracks
            print("Playlist loaded successfully.")
        } catch {
            print("Failed to load playlist:", error)
        }
    }
    
}

private extension URL {
    var isDirectory: Bool {
        (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}
