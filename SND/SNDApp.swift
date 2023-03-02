//
//  SNDApp.swift
//  SND
//
//  Created by Alex Antipov on 20.02.2023.
//

import SwiftUI

@main
struct SNDApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
          MainMenu()
        }
    }
}
