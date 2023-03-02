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

        //playerManager.audioPlayer?.delegate = self

    }
    
    @objc public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully: Bool) {
        //print("In delegate - audioPlayerDidFinishPlaying")
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
        //print("> trackHasEndedEvent")
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
            let track = Track(path: url, filename: url.lastPathComponent)
            DispatchQueue.main.async {
                self.tracks.append(track)
            }
        }
    }
    
    func addFromPaths(urls: [URL]) {
        
        
        for url in urls {
            if url.isDirectory {
                print("It's a directory, trying to load file")
                
                let fileManager = FileManager()
                do {
                    let itemsInDir = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
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
            playerManager.audioPlayer!.delegate = self
        }
    }
}


private extension URL {
    var isDirectory: Bool {
        (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}


//extension SNDPlaylist: NSObject, AVAudioPlayerDelegate {
//
//    var player = AVAudioPlayer()
//
//        init(){
//            player.delegate = self
//        }
//
//    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully: Bool) {
//        print("In delegate - audioPlayerDidFinishPlaying")
//    }
//
//}
