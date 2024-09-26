//
//  Track.swift
//  SND
//
//  Created by Alex Antipov on 21.02.2023.
//

import Foundation

struct Metadata {
    var artist: String?
}

struct Track: Hashable, Identifiable, Codable {
    var id: String = UUID().uuidString
    var state: Bool = false
    //var num: Int?
    var path: URL
    var filename: String
    
    var stateAsString: String {
        self.state ? ">" : ""
    }
    
    // Define a CodingKeys enum if you want to customize how the fields are encoded/decoded
    enum CodingKeys: String, CodingKey {
        case id, state, path, filename
    }
}
