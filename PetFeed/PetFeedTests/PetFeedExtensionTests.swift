//
//  PetFeedExtensionTests.swift
//  PetFeedTests
//
//  Created by Danko, Radoslav on 08/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import XCTest
import os.log
@testable import PetFeed

class PetFeedExtensionTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPetImage() throws {
        //given
        let pet = Pet("dog1.jpg", isFavourite: false)
        //when
        let cache = PetApiMock().cache
        //then
        let image = pet.image(from: cache)
    
        XCTAssertNotNil(image, "Pet Extension should return cached image")
    }

 func testPetUIImage() throws {
     //given
     let pet = Pet("dog1.jpg", isFavourite: false)
     //when
     let cache = PetApiMock().cache
     //then
     let image = pet.uiImage(from: cache)
 
     XCTAssertNotNil(image, "Pet Extension should return cached UIImage")
 }
    
    func testDataToImage() throws {
        //given
        let mock = PetApiMock()
        //when
        let imageData = mock.petImageData()
        //then
        let image = imageData?.asImage()
        
        XCTAssertNotNil(image, "Valid Image Data should be converted to Image")
    }
    
    func testInvalidDataToNil() throws {
        //given
        //when
        let imageData = "TEST".data(using: .utf8)
        //then
        let image = imageData?.asImage()
        
        XCTAssertNil(image, "Invalid Data should NOT be converted to Image")
    }
    
    func testLogTypeData() throws {
        //given
        let log = Log.data()
        //when
        let result = log.associatedValue() == OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "data")
        //then
        log.fault(message: "test")
        XCTAssertTrue(result, "Log Data should be OS Log category data")
        
    }
    
    func testLogTypeNetworking() throws {
        //given
        let log = Log.networking()
        //when
        let result = log.associatedValue() == OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "networking")
        //then
        log.info(message: "test")
        XCTAssertTrue(result, "Log Data should be OS Log category networking")
        
    }
    
    func testLogTypeUser() throws {
        //given
        let log = Log.user()
        //when
        let result = log.associatedValue() == OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "user")
        //then
        log.error(message: "test")
        XCTAssertTrue(result, "Log Data should be OS Log category user")
        
    }

}
