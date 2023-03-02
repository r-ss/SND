//
//  PlayPauseButtonView.swift
//  SND
//
//  Created by Alex Antipov on 22.02.2023.
//


import SwiftUI

struct PlayPauseButtonView: View {
    
    @State var icon_name: String = "play.fill"
    var onClick: (() -> Void) /// use closure for callback
    
    
    var body: some View {
        
        Button(action: onClick) {
            HStack {

                    Image(systemName: icon_name)
//                        .font(.regularCustom)
                
            }
            .padding(12)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .onAppear(){
            
            NotificationCenter.simple(name: .playbackStarted){
                icon_name = "pause.fill"
            }
            
            NotificationCenter.simple(name: .playbackStopped){
                icon_name = "play.fill"
            }
            
        }
        
    }
}

//struct PlayPauseButtonView_Previews: PreviewProvider {
//    static var previews: some View {
//        PlayPauseButtonView(title: "Press me", icon_name: "trash", onClick: { print("click")} )
//    }
//}
