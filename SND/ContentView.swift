//
//  ContentView.swift
//  SND
//
//  Created by Alex Antipov on 20.02.2023.
//

import SwiftUI
import UniformTypeIdentifiers

import AVFoundation

struct ContentView: View {
    
    @StateObject var sndPlaylist = SNDPlaylist()
    @StateObject var sndPlayer = SNDPlayer.shared
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 5){
                
                PlayPauseButtonView(onClick: {
                    sndPlayer.playPauseToggle()
                })
                
                ProgressBarView(value: $progressValue).frame(height: 12)
                
                Image(systemName: "speaker.wave.2.circle").resizable().frame(width: 16, height: 16)
                    .padding([.leading, .trailing], 5)
                
                VolumeSliderView(value: $volumeValue).frame(
                    maxWidth: 100, maxHeight: 12)
                
//                Image(systemName: "airplayaudio").resizable().frame(width: 16, height: 16)
//                    .padding([.leading, .trailing], 5)
//                    .onTapGesture{
//                        print("list devices")
//
//                    }
                
                
                
            }.padding(10)
            
            Divider()
            
            // Tab bar between controls and playlist
            TabBarView()
                .frame(height: 30)
            
            PlaylistView(sndPlaylist: sndPlaylist)
                .frame(minWidth: 500, minHeight: 200, alignment: .topLeading)
                .padding(0)
            
        }
        .environmentObject(sndPlaylist)
        .onDrop(of: [.fileURL], isTargeted: nil) {
            itemProviders in
            for provider in itemProviders {
                let _ = provider.loadObject(ofClass: URL.self) { object, error in
                    if let url = object {
                        sndPlaylist.addFromPaths(urls: [url])
                    }
                }
            }
            return true
        }
        .onReceive(timer) { timerTick in
            sndPlayer.updateProgress()
            progressValue = sndPlayer.progress
        }
        .onAppear() {
            
            // Subscribing to File > Add to playlist... menu event
            NotificationCenter.simple(name: .fileOpenDialogRequested){
                if let urls = showOpenPanel() {
                    sndPlaylist.addFromPaths(urls: urls)
                }
            }
            
            // Subscribing to track start event to immedeately set progress bar to zero
            NotificationCenter.simple(name: .playbackStarted){
                progressValue = 0
            }
            
            // Subscribing to new playlist menu event
            NotificationCenter.simple(name: .createNewPlaylistRequested) {
                PlaylistManager.shared.createNewPlaylist(makeActive: true)
            }
        }
        .onKeyPress(keys: [.space]) { _ in
//                print("Spacebar jj")
                sndPlayer.playPauseToggle()
                return .handled
            }
        .alert(isPresented: $sndPlayer.showAlert) {
                    Alert(
                        title: Text("Playback Error"),
                        message: Text(sndPlayer.alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
        
    }
    
    // MARK: Private
    private var timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    @State private var progressValue: Float = 0.0
    @State private var volumeValue: Float = 1.0
    
    private func showOpenPanel() -> [URL]? {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [UTType(filenameExtension: "mp3")!, UTType(filenameExtension: "flac")!]
        openPanel.allowsMultipleSelection = true
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = true
        let response = openPanel.runModal()
        return response == .OK ? openPanel.urls : nil
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
