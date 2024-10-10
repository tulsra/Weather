//
//  RootViewModelTests.swift
//  WeathermanTests
//
//  Created by Thulasi Ram Boddu on 8/10/24.
//

import XCTest
import Combine
@testable import Weatherman

final class RootViewModelTests: XCTestCase {
    
    let mockServiceManager = MockServiceManager()
    let mockDatastoreManager = MockDataStoreManager()
    let mockLocationManager = MockLocationManager()
    var mockWeatherService: MockWeatherSearchService!
    var sut: RootViewModel!
    
    override func setUp() {
        super.setUp()
        //Given
        mockWeatherService = MockWeatherSearchService(service: mockServiceManager, dataStore: mockDatastoreManager)
        sut = RootViewModel(sm: mockWeatherService, lm: mockLocationManager)
    }

    func testSearchTextIsEmpty() {
        //When
        sut.searchText = ""
        //then
        XCTAssertFalse(mockWeatherService.searchFuncCalled)
    }
    
    func testValidSerchTextLength() {
        //When
        sut.searchText = "Lo"
        //then
        XCTAssertFalse(mockWeatherService.searchFuncCalled)
    }
    
    func testValidSearchTextLength() {
        //When
        sut.searchText = "London"
        //Then
        XCTAssertTrue(mockWeatherService.searchFuncCalled)
    }
    
    func testGetWeatherDatafuncCall() {
        //When
        sut.getWeatherData()
        //Then
        XCTAssertTrue(mockWeatherService.getWeatherDataFuncCalled)
    }
}
