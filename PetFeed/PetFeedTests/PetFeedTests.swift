//
//  PetFeedTests.swift
//  PetFeedTests
//
//  Created by Danko, Radoslav on 03/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import XCTest
import CoreData
import Combine
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

extension NSManagedObjectContext {

    class func contextForTests() -> NSManagedObjectContext {
        // Get the model
        let model = NSManagedObjectModel.mergedModel(from: Bundle.allBundles)!

        // Create and configure the coordinator
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        try! coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)

        // Setup the context
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        return context
    }

}

class PetFeedTests: XCTestCase {

    var environment: PetEnvironment!
    let apiURL = URL(string: "https://shibe.online/api/shibes")!
    let context =  NSManagedObjectContext.contextForTests()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockUrlProtocol.self]
        let localApi = LocalPetApi(managedObjectContext: context)
        let networkApi = NetworkPetApi(localRepository: localApi)
        environment = PetEnvironment(networkService: networkApi,
                                     localService: localApi)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFetchAction() throws {
        //given
        let store = PreviewSupport.petStoreMock
        //when
        store.send(.fetch(page: 1))
        var sinkCount = 0
        //then
        let exp = XCTestExpectation(description: "Test Fetch Action")
        let subscription = store.$state.sink { state in
            if sinkCount == 1 { // sink 0 is initial State
                XCTAssertNotNil(state.fetchResult, "Fetch action should set the results into the App")
                exp.fulfill()
            }
            sinkCount += 1
        }
        
        XCTAssertNotNil(subscription)

        wait(for: [exp], timeout: 2.0)
    }
    
    func testFetchFavouriteAction() throws {
        //given
        let store = PreviewSupport.favouritePetStoreMock
        //when
        store.send(.fetch(page: 1))
        let exp = XCTestExpectation(description: "Test Fetch Favourite Action")
        //then
        var sinkCount = 0
        let subscription = store.$state.sink { state in
            if sinkCount == 1 {// sink 0 is initial State
                XCTAssertFalse(state.fetchResult.isEmpty, "Fetch Favourite action should set the results into the App")
                exp.fulfill()
            }
            sinkCount += 1
        }
        
        XCTAssertNotNil(subscription)

        wait(for: [exp], timeout: 2.0)
    }
    
    func testSetPetAction() throws {
        //given
        let store = PreviewSupport.managePetStoreMock
        //when
        let exp = XCTestExpectation(description: "Test Set Pet Action")
        store.send(.updatePet(Pet("test", isFavourite: true), favourite: false, petState: PreviewSupport.petStoreMock.state))
        //then
        var sinkCount = 0
        let subscription = store.$state.sink { state in
            if sinkCount == 1 {// sink 0 is initial State
                XCTAssertNotNil(state.updatedPet, "Update pet action should set the updatedPet into the App")
                exp.fulfill()
            }
            sinkCount += 1
        }
        
        XCTAssertNotNil(subscription)

        wait(for: [exp], timeout: 2.0)
    }
    
    func testPetDecoding() throws {
        //given
        let jsonString = #"""
            ["https://cdn.shibe.online/shibes/01ffe1d5c4fca383bcd389219055132d0783c2b6.jpg","https://cdn.shibe.online/shibes/79a12b495eadac635c74c21770c1e7f63e050ab1.jpg","https://cdn.shibe.online/shibes/288ff16fd6303f214f637946163617b2acac521c.jpg","https://cdn.shibe.online/shibes/74079100c8374fd88ac3e735d3c264d6f633dafc.jpg","https://cdn.shibe.online/shibes/4da0e01134cf69896ffc370f233e907fcca7a77f.jpg"]
            """#

        //when
        if let jsonData = jsonString.data(using: .utf8) {
            if let petsUrls = try? JSONDecoder().decode([String].self, from: jsonData) {
                let pets = petsUrls.map {Pet.init($0, isFavourite: false)}
                //then
                XCTAssertFalse(pets.isEmpty, "Pets Json must be decoded successfully")
            } else {
                XCTFail("Pets Json must be parsed successfully")
            }

        } else {
            XCTFail("Pets Json must not be empty")
        }

    }

    func testPetFetchSuccess() throws {
        //given
        let localApi = LocalPetApi(managedObjectContext: context)
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.protocolClasses = [MockUrlProtocol.self]
        let networkApi = NetworkPetApi(sessionConfiguration: sessionConfig, localRepository: localApi)
        let mockedEnvironment = PetEnvironment(networkService: networkApi,
                                     localService: localApi)
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
        let request = ShibeRequest(count: 4)
        let subscription = mockedEnvironment
            .networkService
            .fetch(request).sink(receiveCompletion: { completion in
            if case .failure = completion {
                XCTFail("Pet fetch should succeed")
            }
            exp.fulfill()
        }, receiveValue: { pets in
            //then
            XCTAssertFalse(pets.isEmpty)
        })
        XCTAssertNotNil(subscription)

        wait(for: [exp], timeout: 1.0)
    }

    func testPetFetchError() throws {
        //given
        let localApi = LocalPetApi(managedObjectContext: context)
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.protocolClasses = [MockUrlProtocol.self]
        let networkApi = NetworkPetApi(sessionConfiguration: sessionConfig, localRepository: localApi)
        let mockedEnvironment = PetEnvironment(networkService: networkApi,
                                     localService: localApi)
        
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
        let request = ShibeRequest(count: 4)
        let subscription = mockedEnvironment
            .networkService
            .fetch(request).sink(receiveCompletion: { completion in
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

    func testSetPetLocal() throws {
        //given
        let imageData = PetApiMock().petImageData()
        let pet = Pet("test", isFavourite: false)
        //when
        let exp = XCTestExpectation(description: "Test Set Favourite Pet")
        let subscription = environment
            .localService
            .setPet(pet, image: imageData, favourite: true)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Pet Favourite save should succeed")
                }
                exp.fulfill()
            }, receiveValue: { updatedPet in
                //then
                XCTAssertTrue(!updatedPet.url.isEmpty)
            })

        XCTAssertNotNil(subscription)

        wait(for: [exp], timeout: 110.0)
    }

    func testFetchLocal() throws {
        //given
        let imageData = PetApiMock().petImageData()
        let pet = Pet("test", isFavourite: false)
        //when
        let exp = XCTestExpectation(description: "Test Fetch Local")

        let subscription = environment
            .localService
            .setPet(pet, image: imageData, favourite: true)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Pet Favourite save should succeed")
                }
            }, receiveValue: { [weak self] _ in
                _ = self?.environment
                    .localService
                    .fetchFavourites(page: 1)
                    .sink(receiveCompletion: { completion in
                        if case .failure(_) = completion {
                            //then
                            XCTFail("Should return Local Pets")
                        }
                        exp.fulfill()
                    }, receiveValue: { pets in
                        XCTAssertFalse(pets.isEmpty, "Pet fetch should return Local Pets")
                    })
            })

        XCTAssertNotNil(subscription)

        wait(for: [exp], timeout: 2.0)
    }
    
    func testFetchArrayLocal() throws {
        //given
        let imageData = PetApiMock().petImageData()
        let pet = Pet("test", isFavourite: false)
        //when
        let exp = XCTestExpectation(description: "Test Fetch Local")

        let subscription = environment
            .localService
            .setPet(pet, image: imageData, favourite: true)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Pet Favourite save should succeed")
                }
            }, receiveValue: { [weak self] _ in
                
                let urls = self?.environment.localService.fetchFavouritesIds()
                XCTAssertFalse(urls?.isEmpty ?? false, "Local Favourite Pets URLS should not be empty")
                exp.fulfill()
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
        let subscription = environment
            .networkService
            .download(self.apiURL)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Pet image download should succeed")
                }
                exp.fulfill()
            }, receiveValue: { image in
                //then
                XCTAssertFalse(image.isEmpty)
            })
        XCTAssertNotNil(subscription)

        wait(for: [exp], timeout: 1.0)
    }
    
    func testImageLoaderDownloadSuccess() throws {
        //given
        let imageLoader = ImageLoader(url: URL(string: "dog1.jpg"), cache: nil, service: PetApiMock())
        var sinkCount = 0
        //when
        let exp = XCTestExpectation(description: "Test Download")
        imageLoader.load()
            
        let subscription = imageLoader.$image.eraseToAnyPublisher().sink { image in
            if sinkCount == 1 {
                //then
                XCTAssertTrue(image != nil)
                exp.fulfill()
            }
            sinkCount += 1
        }
        XCTAssertNotNil(subscription)

        wait(for: [exp], timeout: 100.0)
    }
    
    

}
