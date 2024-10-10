//
//  ProcessInfoCheck.swift
//  Weatherman
//
//  Created by Thulasi Ram Boddu on 8/10/24.
//

import Foundation

final class ProcessInfoCheck {
    static let testMode = ProcessInfo.processInfo.arguments.contains("TestMode") || ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
}
