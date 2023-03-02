//
//  ProgressBar.swift
//  SND
//
//  Created by Alex Antipov on 22.02.2023.
//

import SwiftUI

struct ProgressBarView: View {
    @Binding var value: Float
    
//    @ObservedObject var sndPlayer: SNDPlayer
    var sndPlayer = SNDPlayer.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color(.systemTeal))
                
                //                withAnimation(.linear) {
                Rectangle().frame(width: min(CGFloat(self.value)*geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(Color(.systemBlue))
                //                }
            }
            .cornerRadius(4.0)
            .onTapGesture{ location in
                let percent = location.x / geometry.size.width
                sndPlayer.playFromPosition(percent: Double(percent))
                value = sndPlayer.progress
            }
        }
    }
}
