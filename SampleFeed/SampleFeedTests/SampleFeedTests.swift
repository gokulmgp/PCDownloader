//
//  SampleFeedTests.swift
//  SampleFeedTests
//
//  Created by Prasad on 18/05/19.
//  Copyright © 2019 Prasad. All rights reserved.
//

import XCTest
@testable import PCDownloader
@testable import SampleFeed

class SampleFeedTests: XCTestCase {

    var model: Model!
    var pcDownloader = PCDownloader(cacheTime: 1, memorySpace: 250, diskSpace: 250)
    override func setUp() {
        
        model = Model(downloader: pcDownloader)
         model.makeApiCall { (data, state) in
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCheckingDataAvailability()
    {
        let promise = expectation(description: "Base URL Working")
        XCTAssertEqual(model.items?.count, 0, "the array is empty")
        
        model.makeApiCall { (data, state) in
            if(self.model.items!.count > 0)
            {
                promise.fulfill()
            }
            else
            {
                XCTAssert(false)
            }
            
            XCTAssertEqual(self.model.items?.count, 10, "Data correct")
        }
        
        wait(for: [promise], timeout: 5)
        
    }
    
    func testImageDownloading()
    {
        let promise = expectation(description: "Image downloading Working")

        var array:[Any?] = []
        
        model.makeApiCall { (data, state) in
            if(self.model.items!.count > 0)
            {
                for index in 0..<self.model.items!.count
                {
                    let item = self.model!.items![index] as! Item
                    
                    _ =  self.pcDownloader.imageWithURL(URL(string:item.urls.regular!)!) { (image) in
                        if  (image != nil)
                        {
                            array.append(image)
                            
                            if (array.count == 9)
                            {
                                promise.fulfill()
                                
                                XCTAssert(true)
                            }
                        }
                    }
                    
                }
            }
        }
        wait(for: [promise], timeout: 25)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
