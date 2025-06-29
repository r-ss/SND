//
//  SNDPlaylist.swift
//  SND
//
//  Created by Alex Antipov on 20.02.2023.
//

import Foundation
import AVFoundation

// Add notification name for playlist switching
extension Notification.Name {
    static let playlistSwitched = Notification.Name("playlistSwitched")
}

// PlaylistManager to handle multiple playlists
class PlaylistManager: ObservableObject {
    static let shared = PlaylistManager()
    
    @Published var playlists: [PlaylistTab] = []
    @Published var activePlaylistId: String = ""
    
    var activePlaylist: PlaylistTab? {
        get {
            playlists.first(where: { $0.id == activePlaylistId })
        }
        set {
            if let index = playlists.firstIndex(where: { $0.id == activePlaylistId }) {
                playlists[index] = newValue ?? playlists[index]
            }
        }
    }
    
    private init() {
        // Try to migrate old playlist.json if it exists
        migrateOldPlaylist()
        
        loadPlaylists()
        if playlists.isEmpty {
            createNewPlaylist(name: "Playlist 1", makeActive: true)
        }
    }
    
    func createNewPlaylist(name: String? = nil, makeActive: Bool = false) {
        let playlistName = name ?? "Playlist \(playlists.count + 1)"
        let newPlaylist = PlaylistTab(name: playlistName, isActive: makeActive)
        
        if makeActive {
            // Deactivate all other playlists
            for index in playlists.indices {
                playlists[index].isActive = false
            }
            activePlaylistId = newPlaylist.id
        }
        
        playlists.append(newPlaylist)
        savePlaylists()
        
        // If we made it active, notify SNDPlaylist to update its tracks
        if makeActive {
            NotificationCenter.default.post(name: .playlistSwitched, object: nil)
        }
    }
    
    func switchToPlaylist(id: String) {
        guard let index = playlists.firstIndex(where: { $0.id == id }) else { return }
        
        // Deactivate all playlists
        for i in playlists.indices {
            playlists[i].isActive = false
        }
        
        // Activate selected playlist
        playlists[index].isActive = true
        activePlaylistId = id
        savePlaylists()
        
        // Notify SNDPlaylist to update its tracks
        NotificationCenter.default.post(name: .playlistSwitched, object: nil)
    }
    
    func renamePlaylist(id: String, newName: String) {
        guard let index = playlists.firstIndex(where: { $0.id == id }) else { return }
        playlists[index].name = newName
        savePlaylists()
    }
    
    func deletePlaylist(id: String) {
        // Don't delete if it's the last playlist
        guard playlists.count > 1 else { return }
        
        guard let index = playlists.firstIndex(where: { $0.id == id }) else { return }
        let wasActive = playlists[index].isActive
        
        playlists.remove(at: index)
        
        // If deleted playlist was active, activate another one
        if wasActive && !playlists.isEmpty {
            switchToPlaylist(id: playlists[0].id)
        }
        
        savePlaylists()
    }
    
    func addTracksToActivePlaylist(_ tracks: [Track]) {
        guard let index = playlists.firstIndex(where: { $0.id == activePlaylistId }) else { return }
        playlists[index].tracks.append(contentsOf: tracks)
        savePlaylists()
    }
    
    func updateActivePlaylistTracks(_ tracks: [Track]) {
        guard let index = playlists.firstIndex(where: { $0.id == activePlaylistId }) else { return }
        playlists[index].tracks = tracks
        savePlaylists()
    }
    
    // MARK: - Persistence
    
    private func getPlaylistsFileURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("playlists.json")
    }
    
    func savePlaylists() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(playlists)
            let url = getPlaylistsFileURL()
            try data.write(to: url)
            print("Playlists saved successfully.")
        } catch {
            print("Failed to save playlists:", error)
        }
    }
    
    func loadPlaylists() {
        let decoder = JSONDecoder()
        let url = getPlaylistsFileURL()
        
        do {
            let data = try Data(contentsOf: url)
            playlists = try decoder.decode([PlaylistTab].self, from: data)
            
            // Find and set active playlist
            if let activePlaylist = playlists.first(where: { $0.isActive }) {
                activePlaylistId = activePlaylist.id
            } else if !playlists.isEmpty {
                // If no active playlist, activate the first one
                playlists[0].isActive = true
                activePlaylistId = playlists[0].id
            }
            
            print("Playlists loaded successfully.")
        } catch {
            print("Failed to load playlists:", error)
        }
    }
    
    private func migrateOldPlaylist() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let oldPlaylistURL = documentsDirectory.appendingPathComponent("playlist.json")
        let newPlaylistsURL = getPlaylistsFileURL()
        
        // Check if old playlist exists but new playlists don't
        if FileManager.default.fileExists(atPath: oldPlaylistURL.path) &&
           !FileManager.default.fileExists(atPath: newPlaylistsURL.path) {
            
            // Try to load old playlist
            let decoder = JSONDecoder()
            do {
                let data = try Data(contentsOf: oldPlaylistURL)
                let tracks = try decoder.decode([Track].self, from: data)
                
                // Create a new playlist with the old tracks
                let migratedPlaylist = PlaylistTab(name: "Playlist 1", tracks: tracks, isActive: true)
                playlists = [migratedPlaylist]
                savePlaylists()
                
                // Rename old file to backup
                let backupURL = documentsDirectory.appendingPathComponent("playlist.json.backup")
                try FileManager.default.moveItem(at: oldPlaylistURL, to: backupURL)
                
                print("Successfully migrated old playlist to new format")
            } catch {
                print("Failed to migrate old playlist:", error)
            }
        }
    }
}

class SNDPlaylist: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    private let playerManager = SNDPlayer.shared
    private let playlistManager = PlaylistManager.shared
    
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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playlistSwitched),
            name: .playlistSwitched,
            object: nil
        )
        
        // Load tracks from active playlist
        syncWithActivePlaylist()
        
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
                self.playlistManager.updateActivePlaylistTracks(self.tracks)
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
        self.playlistManager.updateActivePlaylistTracks(self.tracks)
    }
    
    
    @objc private func playlistSwitched() {
        syncWithActivePlaylist()
    }
    
    private func syncWithActivePlaylist() {
        if let activePlaylist = playlistManager.activePlaylist {
            self.tracks = activePlaylist.tracks
        }
    }
    
}

private extension URL {
    var isDirectory: Bool {
        (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}
