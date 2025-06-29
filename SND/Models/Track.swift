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
    var bookmarkData: Data?
    
    var stateAsString: String {
        self.state ? ">" : ""
    }
    
    // Define a CodingKeys enum if you want to customize how the fields are encoded/decoded
    enum CodingKeys: String, CodingKey {
        case id, state, path, filename, bookmarkData
    }
    
    // Create bookmark data for the track's URL
    mutating func createBookmark() {
        do {
            self.bookmarkData = try path.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
        } catch {
            print("Failed to create bookmark for \(filename): \(error)")
        }
    }
    
    // Resolve bookmark data to get accessible URL
    func resolveBookmark() -> URL? {
        guard let bookmarkData = bookmarkData else { return path }
        
        do {
            var isStale = false
            let resolvedURL = try URL(
                resolvingBookmarkData: bookmarkData,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            
            if isStale {
                print("Bookmark is stale for \(filename)")
            }
            
            return resolvedURL
        } catch {
            print("Failed to resolve bookmark for \(filename): \(error)")
            return path
        }
    }
}
