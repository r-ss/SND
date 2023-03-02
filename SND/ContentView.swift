//
//  ContentView.swift
//  SND
//
//  Created by Alex Antipov on 20.02.2023.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    
    //    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect() // to update progressbar
    
    private var timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    @StateObject var sndPlaylist = SNDPlaylist()
    var sndPlayer = SNDPlayer.shared
    
    @State var progressValue: Float = 0.0
    @State var volumeValue: Float = 1.0
    
    func showOpenPanel() -> [URL]? {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [UTType(filenameExtension: "mp3")!, UTType(filenameExtension: "flac")!]
        openPanel.allowsMultipleSelection = true
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = true
        let response = openPanel.runModal()
        return response == .OK ? openPanel.urls : nil
    }
    
    
    var body: some View {
        VStack {
            HStack(spacing: 5){
                
                PlayPauseButtonView(onClick: {
                    sndPlayer.playPauseToggle()
                })
                
                ProgressBarView(value: $progressValue).frame(height: 12)
                
                Image(systemName: "speaker.wave.2.circle").resizable().frame(width: 16, height: 16)
                    .padding([.leading, .trailing], 5)
                
                VolumeSliderView(value: $volumeValue).frame(
                    maxWidth: 100, maxHeight: 12)
                
            }.padding(10)
            
//            Button("Open") {
//                if let urls = showOpenPanel() {
//                    sndPlaylist.addFromPaths(urls: urls)
//                }
//            }
                
            PlaylistView(sndPlaylist: sndPlaylist)
                .frame(minWidth: 500, minHeight: 200, alignment: .topLeading)
                .padding(0)
            
            
        }
        .environmentObject(sndPlaylist)
//        .environmentObject(sndPlayer)
        .onDrop(of: [.fileURL], isTargeted: nil) { itemProviders in
            for provider in itemProviders {
                let _ = provider.loadObject(ofClass: URL.self) { object, error in
                    if let url = object {
                        
                        print("ss")
                            sndPlaylist.addFromPaths(urls: [url])
                        
//                        print("url: \(url.pathExtension.lowercased())")
//                        if ["flac", "mp3"].contains(url.pathExtension.lowercased()) {
//                            DispatchQueue.main.async {url
//                                sndPlaylist.addTrack(track: Track(path: url, filename: String(describing: url.lastPathComponent)))
//                            }
//                        }
                        
                        
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
            NotificationCenter.simple(name: .fileOpenDialogRequested){
                if let urls = showOpenPanel() {
                    sndPlaylist.addFromPaths(urls: urls)
                }
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

func describeDroppedURL(_ url: URL) -> String {
    do {
        var messageRows: [String] = []
        
        if try url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory == false {
            messageRows.append("Dropped file named `\(url.lastPathComponent)`")
            
            messageRows.append("which starts with `\(try String(contentsOf: url).components(separatedBy: "\n")[0]))`")
        } else {
            messageRows.append("Dropped folder named `\(url.lastPathComponent)`")
            
            for childUrl in try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: []) {
                messageRows.append("  Containing file named `\(childUrl.lastPathComponent)`")
                
                messageRows.append("    which starts with `\((try String(contentsOf: childUrl)).components(separatedBy: "\n")[0])`")
            }
        }
        
        return messageRows.joined(separator: "\n")
    } catch {
        return "Error: \(error)"
    }
}


