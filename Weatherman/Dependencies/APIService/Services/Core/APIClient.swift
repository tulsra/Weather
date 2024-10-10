//
//  APIClient.swift
//  Weatherman
//
//  Created by Thulasi Ram Boddu on 10/9/24.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum APIError: Error {
    case invalidRequest
    case invalidStatus
    case noData
    case generic(Error)
    case serviceError(Error)
}

protocol API {
    var configuration: Configuration { get }
    var baseURL: String? { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var defaultHttpHeaders: [String: String] { get }
    var additionalHeaders: [String: String]? { get }
}

protocol APIQueryParameters {
    /// URL Query parameters.
    var queryParameters: [String: String]? { get }
}

protocol APIGet: API, APIQueryParameters {}

extension API {
    /// Default configuration
    var configuration: Configuration {
        return LabConfiguration()
    }
    /// Headers sent to all the requests.
    var defaultHttpHeaders: [String: String] {
        [
            "Content-Type": "application/json",
            "Accept": "application/json",
        ]
    }
    
    /// Default baseURL used across the app can be overridden for a particular api by overriding this.
    var baseURL: String? { configuration.baseURL }
    
    /// Default type of additionalHeaders
    var additionalHeaders: [String: String]? { nil }
}

extension APIGet {
    /// Always returns .get HTTPMethod.
    var method: HTTPMethod { .get }
    /// Default queryParameters.
    var queryParameters: [String: String]? { nil }
}
