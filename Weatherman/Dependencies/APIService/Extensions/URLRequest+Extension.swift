//
//  URLRequest+Extension.swift
//  Weatherman
//
//  Created by Thulasi Ram Boddu on 10/9/24.
//

import Foundation

extension URLRequest {
    /// Constructor from an `API` object
    /// - Parameters:
    ///   - api: `API` description from which we must create the `URLRequest`
    ///   - baseURL: base URL of the API Endpoints.
    init?(api: API, baseURL: URL?) {
        guard var urlComponents = URLComponents(api: api, baseURL: baseURL)
        else { return nil }

        if let apiGet = api as? APIQueryParameters,
            let queryParameters = apiGet.queryParameters
        {
            urlComponents.queryItems = queryParameters.sorted(by: <).map(URLQueryItem.init)
            urlComponents.percentEncodedQuery = urlComponents.percentEncodedQuery?
                .replacingOccurrences(of: "+", with: "%2B")
        }

        guard let url = urlComponents.url
        else { return nil }

        self.init(url: url)

        httpMethod = api.method.rawValue
        api.defaultHttpHeaders.forEach {
            addValue($0.1, forHTTPHeaderField: $0.0)
        }
        api.additionalHeaders?.forEach {
            addValue($0.1, forHTTPHeaderField: $0.0)
        }
    }
}

extension URLComponents {
    init?(api: API, baseURL: URL?) {
        guard let baseURL = baseURL else { return nil }
        let url = baseURL.appendingPathComponent(api.path)
        self.init(url: url, resolvingAgainstBaseURL: false)
    }
}
