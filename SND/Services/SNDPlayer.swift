//
//  SNDPlayer.swift
//  SND
//
//  Created by Alex Antipov on 20.02.2023.
//

import AVFoundation
//import CoreAudio

class SNDPlayer: ObservableObject {
    static let shared = SNDPlayer()
    
    var audioPlayer: AVAudioPlayer?
    
    var currentTrack: Track?
    var ctPosition: Double?
    var ctDuration: Double?
    

    
    var progress: Float {
        if let p = ctPosition, let d = ctDuration {
            return Float(p/d)
        }
        return 0.0
    }
    
    //    var isAudioPlaying: Bool {
    //        if let p = audioPlayer {
    //            if p.isPlaying{
    //                return true
    //            }
    //        }
    //        return false
    //    }
    
    func playFromPosition(percent: Double) {
        if let p = audioPlayer {
            let seconds: TimeInterval = percent * p.duration
            p.currentTime = seconds
            self.updateProgress()
            Notification.fire(name: .playbackRewinded)
        }
    }
    
    func updateProgress() {
        if let _ = audioPlayer {
            self.ctPosition = audioPlayer?.currentTime
            self.ctDuration = audioPlayer?.duration
        }
    }
    
    func setVolume(_ volume: Float){
        if let p = audioPlayer {
            p.setVolume(volume, fadeDuration: 0.25)
        }
    }
    
    
    //    func play(url: URL) {
    //        do {
    //            audioPlayer = try AVAudioPlayer(contentsOf: url) //<- No `let`
    //            audioPlayer?.prepareToPlay()
    //            audioPlayer?.play()
    //            Notification.fire(name: .playbackStarted)
    //            //print("sound is playing")
    //        } catch let error {
    //            print("Sound Play Error -> \(error)")
    //        }
    //    }
    //
    func play(track: Track) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: track.path) //<- No `let`
            
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            currentTrack = track
            Notification.fire(name: .playbackStarted)
            //print("sound is playing")
        } catch let error {
            print("Sound Play Error -> \(error)")
        }
    }
    
    //    func stop(){
    //        audioPlayer?.stop()
    //        audioPlayer = nil
    //        Notification.fire(name: .playbackStopped)
    //    }
    
    func playPauseToggle(){
        if let p = audioPlayer {
            if p.isPlaying {
                //                p.stop()
                p.pause()
                Notification.fire(name: .playbackStopped)
            } else {
                p.play()
                Notification.fire(name: .playbackStarted)
            }
        }
    }
    
    func listAirplayDevices() {
        print("list ap d")
        
    }
    
}
