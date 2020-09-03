//
//  PetFeedTests.swift
//  PetFeedTests
//
//  Created by Danko, Radoslav on 03/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import XCTest
@testable import PetFeed

class PetFeedTests: XCTestCase {

    var petApi: PetApi!
    var expectation: XCTestExpectation!
    let apiURL = URL(string: "https://testSuccess")!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockUrlProtocol.self]
        petApi = PetApi(sessionConfiguration: configuration)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPetDecoding() throws {
        //given
        let jsonString = #"""
            ["https://cdn.shibe.online/shibes/01ffe1d5c4fca383bcd389219055132d0783c2b6.jpg","https://cdn.shibe.online/shibes/79a12b495eadac635c74c21770c1e7f63e050ab1.jpg","https://cdn.shibe.online/shibes/288ff16fd6303f214f637946163617b2acac521c.jpg","https://cdn.shibe.online/shibes/74079100c8374fd88ac3e735d3c264d6f633dafc.jpg","https://cdn.shibe.online/shibes/4da0e01134cf69896ffc370f233e907fcca7a77f.jpg"]
            """#
        
        //when
        if let jsonData = jsonString.data(using: .utf8) {
            if let petsUrls = try? JSONDecoder().decode([String].self, from: jsonData) {
                var pets = petsUrls.map{Pet.init($0)}
                //then
                XCTAssertFalse(pets.isEmpty ?? true, "Pets Json must be decoded successfully")
            } else {
                XCTFail("Pets Json must be parsed successfully")
            }
            
        } else {
            XCTFail("Pets Json must not be empty")
        }
        
    }
    
    func testPetFetchSuccess() throws {
        //given
        let jsonString = #"""
            ["https://cdn.shibe.online/shibes/01ffe1d5c4fca383bcd389219055132d0783c2b6.jpg","https://cdn.shibe.online/shibes/79a12b495eadac635c74c21770c1e7f63e050ab1.jpg","https://cdn.shibe.online/shibes/288ff16fd6303f214f637946163617b2acac521c.jpg","https://cdn.shibe.online/shibes/74079100c8374fd88ac3e735d3c264d6f633dafc.jpg","https://cdn.shibe.online/shibes/4da0e01134cf69896ffc370f233e907fcca7a77f.jpg"]
            """#
        let jsonData = jsonString.data(using: .utf8)
        MockUrlProtocol.requestHandler = { request in
          guard let url = request.url, url == self.apiURL else {
            throw PetFailure.invalidRequest
          }
          
          let response = HTTPURLResponse(url: self.apiURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
          return (response, jsonData)
        }
        //when
        let request = PetRequest(count: 4)
        let subscription = petApi.fetch(request).sink(receiveCompletion: { completion in
            if case .failure(let error) = completion {
                XCTFail("Pet fetch should succeed")
            }
        }, receiveValue: { pets in
            XCTAssertFalse(pets.isEmpty)
        })
        XCTAssertNotNil(subscription)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
