//
//  Configuration.swift
//  Weatherman
//
//  Created by Thulasi Ram Boddu on 10/9/24.
//

import Foundation

protocol Configuration {
    /// Weather service api key
    var apiKey: String { get }
    /// Weaather service base url
    var baseURL: String { get }
}

final class ProductionConfiguration: Configuration {
    let apiKey: String = "f162a47af7e8078fa1c8bbbe35683d01"
    let baseURL: String = "http://api.openweathermap.org"
}

final class LabConfiguration: Configuration {
    let apiKey: String = "f162a47af7e8078fa1c8bbbe35683d01" //Key for lab environment
    let baseURL: String = "http://api.openweathermap.org" //url for lab environment
}
