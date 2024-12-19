//
//  LiveStreamPlaybackTests.swift
//  LiveStreamPlaybackTests
//
//  Created by rudra misra on 19/12/24.
//

import XCTest
@testable import LiveStreamPlayback

final class LiveStreamPlaybackTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    var viewModel: VideoViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = VideoViewModel()
    }
    
    func testFetchVideos() {
        let expectation = self.expectation(description: "Fetching videos")
        
        viewModel.fetchVideos { result in
            switch result {
            case .success(let videos):
                XCTAssertGreaterThan(videos.count, 0)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Failed to fetch videos: \(error)")
            }
        }
        
        waitForExpectations(timeout: 5)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
