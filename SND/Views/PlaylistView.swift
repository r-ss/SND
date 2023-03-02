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
    @State private var selection: Track.ID?
    var body: some View {
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
        .onAppear(){
            //addMockTracks()
        }
        .onChange(of: sortOrder) { newOrder in
            sndPlaylist.tracks.sort(using: newOrder)
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
