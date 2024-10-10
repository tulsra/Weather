//
//  WeathermanUITests.swift
//  WeathermanUITests
//
//  Created by Thulasi Ram Boddu on 10/9/24.
//

import XCTest

final class WeathermanUITests: XCTestCase {

    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["TestMode"]
        app.launch()
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app = nil
    }
    
    func testNoDataTextAvailable() {
        let noDataText = app.staticTexts["no.data.available"]
        // Check if the  text is visible
        XCTAssertTrue(noDataText.exists)
    }
}
