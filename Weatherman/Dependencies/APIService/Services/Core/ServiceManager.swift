//
//  ServiceManager.swift
//  Weatherman
//
//  Created by Thulasi Ram Boddu on 10/9/24.
//

import Combine
import Foundation

protocol ServiceManagerProtocol {
    func execute<T: Decodable>(_ api: API) -> AnyPublisher<T, APIError>
}

final class ServiceManager: ServiceManagerProtocol {
    
    func execute<T: Decodable>(_ api: API) -> AnyPublisher<T, APIError> {
        guard let request = request(from: api)
        else {
            return Fail(error: APIError.invalidRequest).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap({ (data, response) in
                guard let response = response as? HTTPURLResponse,
                      response.statusCode >= 200 && response.statusCode < 300
                else {
                    throw APIError.invalidStatus
                }
                if data.count == 0 { throw APIError.noData }
                return data
            })
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                return APIError.generic(error)
            }
            .eraseToAnyPublisher()
    }
    
    private func request(from api: API) -> URLRequest? {
        guard let baseURL = api.baseURL else { return nil }
       return URLRequest(api: api, baseURL: URL(string: baseURL))
    }
}

// MARK: Test classes

final class MockServiceManager: ServiceManagerProtocol {
    var executeCalled = false
    func execute<T: Decodable>(_ api: API) -> AnyPublisher<T, APIError> {
        executeCalled = true
        return [Data()]
            .publisher
            .map { $0 }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { APIError.generic($0)}
            .eraseToAnyPublisher()
    }
}
