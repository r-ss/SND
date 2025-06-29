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

// TabBarView for multiple playlists
struct TabBarView: View {
    @ObservedObject var playlistManager = PlaylistManager.shared
    @State private var renamingTabId: String? = nil
    @State private var newName: String = ""
    @State private var showingNewPlaylistButton = true
    @State private var isHoveringPlusButton = false
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(playlistManager.playlists) { playlist in
                    TabItemView(
                        playlist: playlist,
                        isActive: playlist.id == playlistManager.activePlaylistId,
                        isRenaming: renamingTabId == playlist.id,
                        newName: $newName,
                        onTap: {
                            playlistManager.switchToPlaylist(id: playlist.id)
                        },
                        onRename: {
                            startRenaming(playlist: playlist)
                        },
                        onDelete: {
                            playlistManager.deletePlaylist(id: playlist.id)
                        },
                        onRenameSubmit: {
                            finishRenaming(playlistId: playlist.id)
                        },
                        onRenamingCancel: {
                            renamingTabId = nil
                            newName = ""
                        }
                    )
                }
                
                // New playlist button with larger clickable area
                Button(action: {
                    playlistManager.createNewPlaylist(makeActive: true)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(isHoveringPlusButton ? .accentColor : .secondary)
                        if isHoveringPlusButton {
                            Text("New Playlist")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(isHoveringPlusButton ? Color.gray.opacity(0.2) : Color.clear)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .onHover { hovering in
                    isHoveringPlusButton = hovering
                }
            }
            .padding(.horizontal, 5)
        }
        .frame(height: 30)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private func startRenaming(playlist: PlaylistTab) {
        renamingTabId = playlist.id
        newName = playlist.name
    }
    
    private func finishRenaming(playlistId: String) {
        if !newName.isEmpty {
            playlistManager.renamePlaylist(id: playlistId, newName: newName)
        }
        renamingTabId = nil
        newName = ""
    }
}

struct TabItemView: View {
    let playlist: PlaylistTab
    let isActive: Bool
    let isRenaming: Bool
    @Binding var newName: String
    let onTap: () -> Void
    let onRename: () -> Void
    let onDelete: () -> Void
    let onRenameSubmit: () -> Void
    let onRenamingCancel: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        Group {
            if isRenaming {
                TextField("", text: $newName, onCommit: onRenameSubmit)
                    .textFieldStyle(PlainTextFieldStyle())
                    .frame(minWidth: 80, maxWidth: 150)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(isActive ? Color.accentColor.opacity(0.3) : Color.clear)
                    .onExitCommand {
                        onRenamingCancel()
                    }
            } else {
                Text(playlist.name)
                    .lineLimit(1)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 5)
                    .background(isActive ? Color.accentColor.opacity(0.3) : (isHovering ? Color.gray.opacity(0.2) : Color.clear))
                    .foregroundColor(isActive ? .primary : .secondary)
                    .onTapGesture {
                        onTap()
                    }
                    .onHover { hovering in
                        isHovering = hovering
                    }
                    .contextMenu {
                        Button("Rename") {
                            onRename()
                        }
                        
                        // Only show delete if there's more than one playlist
                        if PlaylistManager.shared.playlists.count > 1 {
                            Divider()
                            Button("Delete") {
                                onDelete()
                            }
                        }
                    }
            }
        }
        .overlay(
            Rectangle()
                .frame(height: 2)
                .foregroundColor(isActive ? Color.accentColor : Color.clear),
            alignment: .bottom
        )
    }
}
