//
//  Menus.swift
//  SND
//
//  Created by Alex Antipov on 24.02.2023.
//

import SwiftUI

struct MainMenu: Commands {
   var body: some Commands {
    // 3
    EmptyCommands()
       
       
       CommandGroup(before: CommandGroupPlacement.newItem) {
           Button("Add to playlist...") {
               Notification.fire(name: .fileOpenDialogRequested)
           }
           .keyboardShortcut("o", modifiers: .command)
           
           Divider()
           
           Button("New Playlist") {
               NotificationCenter.default.post(name: .createNewPlaylistRequested, object: nil)
           }
           .keyboardShortcut("n", modifiers: [.command, .shift])
       }
       
  }
}
