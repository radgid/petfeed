//
//  PetFeedTests.swift
//  PetFeedTests
//
//  Created by Danko, Radoslav on 03/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import XCTest
@testable import PetFeed

struct Resource {
    let name: String
    let type: String
    let url: URL
    
    init(name: String, type: String, sourceFile: StaticString = #file) throws {
        self.name = name
        self.type = type
        
        // The following assumes that your test source files are all in the same directory, and the resources are one directory down and over
        // <Some folder>
        //  - Resources
        //      - <resource files>
        //  - <Some test source folder>
        //      - <test case files>
        let testCaseURL = URL(fileURLWithPath: "\(sourceFile)", isDirectory: false)
        let testsFolderURL = testCaseURL.deletingLastPathComponent()
        let resourcesFolderURL = testsFolderURL.deletingLastPathComponent().appendingPathComponent("Resources", isDirectory: true)
        self.url = resourcesFolderURL.appendingPathComponent("\(name).\(type)", isDirectory: false)
    }
}

class PetFeedTests: XCTestCase {
    
    var petApi: PetApi!
    let apiURL = URL(string: "https://shibe.online/api/shibes")!
    
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
                var pets = petsUrls.map {Pet.init($0)}
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
            guard let url = request.url, url.absoluteString.contains(self.apiURL.absoluteString) else {
                throw PetFailure.invalidRequest
            }
            
            let response = HTTPURLResponse(url: self.apiURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, jsonData)
        }
        //when
        let exp = XCTestExpectation(description: "Test Fetch")
        let request = PetRequest(count: 4)
        let subscription = petApi.fetch(request).sink(receiveCompletion: { completion in
            if case .failure(let error) = completion {
                XCTFail("Pet fetch should succeed")
            }
            exp.fulfill()
        }, receiveValue: { pets in
            //then
            XCTAssertFalse(pets.isEmpty)
        })
        XCTAssertNotNil(subscription)
        
        wait(for: [exp], timeout: 110.0)
    }
    
    func testPetFetchError() throws {
        //given
        let jsonString = #"""
            ["https:",,,]
            """#
        let jsonData = jsonString.data(using: .utf8)
        MockUrlProtocol.requestHandler = { request in
            guard let url = request.url, url.absoluteString.contains(self.apiURL.absoluteString) else {
                throw PetFailure.invalidRequest
            }
            
            let response = HTTPURLResponse(url: self.apiURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, jsonData)
        }
        //when
        let exp = XCTestExpectation(description: "Test Fetch")
        let request = PetRequest(count: 4)
        let subscription = petApi.fetch(request).sink(receiveCompletion: { completion in
            if case .failure(let error) = completion {
                //then
                if case PetFailure.unwrapingError(_) = error {
                } else {
                    XCTFail("Should report unwrapping error")
                }
            }
            exp.fulfill()
        }, receiveValue: { _ in
            XCTFail("Pet fetch should fail and report data error")
        })
        XCTAssertNotNil(subscription)
        
        wait(for: [exp], timeout: 2.0)
    }
    
    func testPetDownloadSuccess() throws {
        //given
        let file = try? Resource(name: "dog1", type: "jpg")
        let fileData = (try? Data(contentsOf: file!.url))
        
        MockUrlProtocol.requestHandler = { request in
            guard let url = request.url, url.absoluteString.contains(self.apiURL.absoluteString) else {
                throw PetFailure.invalidRequest
            }
            
            let response = HTTPURLResponse(url: self.apiURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, fileData)
        }
        //when
        let exp = XCTestExpectation(description: "Test Download")
        let subscription = petApi.download(self.apiURL)
            .sink(receiveCompletion: { completion in
                if case .failure(_) = completion {
                    XCTFail("Pet image download should succeed")
                }
                exp.fulfill()
            }, receiveValue: { image in
                //then
                XCTAssertFalse(image.isEmpty)
            })
        XCTAssertNotNil(subscription)
        
        wait(for: [exp], timeout: 110.0)
    }
    
}
