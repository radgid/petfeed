//
//  PetFeedUITests.swift
//  PetFeedUITests
//
//  Created by Danko, Radoslav on 03/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import XCTest

class PetFeedUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUIElements() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let scrollView = app.scrollViews.element
        XCTAssertTrue(scrollView.exists,"Main View should have ScrollView present")
        let tabBarButtons = app.tabBars.element.buttons
        XCTAssertTrue(tabBarButtons.count == 2,"There should be two tabs with buttons")
    }
}
