//
//  SNDTests.swift
//  SNDTests
//
//  Created by Alex Antipov on 03.03.2023.
//

import XCTest
@testable import SND

final class SNDTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testURLsSorting() throws {
        let unsorted = Playlist.mocked.playlist.paths
        let sorted = unsorted.sorted(by: { $0.lastPathComponent < $1.lastPathComponent })
        XCTAssertEqual(unsorted.first?.lastPathComponent, "4.mp3")
        XCTAssertEqual(sorted.first?.lastPathComponent, "1.mp3")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
