//
//  SNDPlaylistView.swift
//  SND
//
//  Created by Alex Antipov on 20.02.2023.
//

import SwiftUI

//struct User: Identifiable {
//    let id: Int
//    var name: String
//    var score: Int
//}

struct PlaylistView: View {
    
    @ObservedObject var sndPlaylist: SNDPlaylist
    
    @State private var sortOrder = [KeyPathComparator(\Track.filename)]
    @State private var selection = Set<Track.ID>()
    var body: some View {
        if sndPlaylist.tracks.count == 0 {
            ZStack {
                playlistTable.disabled(true).opacity(0.5)
                Text("Add music by drag files here or using File menu :)")
            }
        } else {
            
            
            playlistTable
                .onAppear(){
                    
                    
                    // TODO: Another way to handle keyboard evengs because this one playing unnecessary chime sound
                    NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { nsevent in
                        
                        switch nsevent.keyCode {
                        case 51:
                            //print("Backspace")
                            sndPlaylist.removeTracksFromPlaylist(ids: selection)
                        default:
                            print(nsevent.keyCode)
                        }
                        
                        return nsevent
                    }
                    
                    
                }
                .onChange(of: sortOrder) { newOrder in
                    sndPlaylist.tracks.sort(using: newOrder)
                }
                //.onChange(of: selection) { items in }
        }
    }
    
    
    
    private var playlistTable: some View {
        Table(selection: $selection, sortOrder: $sortOrder) {
            //        Table(selection: $selection) {
            //            TableColumn("Num", value: \.num)
            //                .width(min: 50, max: 100)
            TableColumn("State", value: \.stateAsString)
                .width(min: 20, max: 40)
            //            TableColumn("Id", value: \.id)
            //                .width(min: 50, max: 100)
            TableColumn("Name", value: \.filename)
            //            TableColumn("Path", value: \.path) { track in
            //                Text(String(contentsOf:track.path))
            //            }
                .width(min: 50)
        } rows: {
            ForEach(sndPlaylist.tracks, content: TableRow.init)
        }
        
        
        .padding(0)
        .contextMenu(forSelectionType: Track.ID.self) { items in
        } primaryAction: { items in
            // This is executed when the row is double clicked
            sndPlaylist.playTrack(trackId: Array(items)[0])
        }
        
    }
    
    private func addMockTracks() {
        let dir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0].appendingPathComponent("snd_audio_mock/8bit")
        sndPlaylist.addFromPaths(urls: [dir])
    }
}

//struct PlaylistView_Previews: PreviewProvider {
//    static var previews: some View {
//        PlaylistView(sndPlaylist: SNDPlaylist())
//    }
//}
