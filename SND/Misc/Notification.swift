//
//  Notifications.swift
//  SND
//
//  Created by Alex Antipov on 19.02.2023.
//

import Foundation

extension Notification.Name {
    //static var appLaunching = Notification.Name("app.launching")
    //static var appClosing = Notification.Name("app.closing")
    
    static var playbackStarted = Notification.Name("playback.started")
    static var playbackStopped = Notification.Name("playback.stopped")
    static var playbackRewinded = Notification.Name("playback.rewinded")
    static var trackHasEnded = Notification.Name("track.has.ended")
    
    static var fileOpenDialogRequested = Notification.Name("menu.file.open.dialog.requested")
    static var createNewPlaylistRequested = Notification.Name("menu.playlist.new.requested")
}

// Method to fire notifications
extension Notification {
    static func fire(name: Notification.Name, payload: Any? = nil){
        NotificationCenter.default.post(name: name, object: nil, userInfo: ["payload":payload ?? "no-data"])
    }
}

// Method to subscribing for notifications
extension NotificationCenter {
    static func listen(name: Notification.Name, completion: @escaping ((Any) -> Void)) {
        
        NotificationCenter.default.addObserver(
            forName: name,
            object: nil,
            queue: .main
        ) { (notification) in
            guard let userInfo = notification.userInfo
            else { return }
            completion(userInfo)
        }
    }
    
    static func simple(name: Notification.Name, completion: @escaping (() -> Void)) {
        
        NotificationCenter.default.addObserver(
            forName: name,
            object: nil,
            queue: .main
        ) { (notification) in
            completion()
        }
    }
}
