//
//  WeatherSearchAPI.swift
//  Weatherman
//
//  Created by Thulasi Ram Boddu on 10/9/24.
//

import Combine
import Foundation

protocol WeatherSearchServiceProtocol {
    var models: CurrentValueSubject<[WeatherDataModel], Never>{ get }
    func search(_ text: String)
    func getWeatherData()
}

final class WeatherSearchService {
    
    private let sm: ServiceManagerProtocol
    private let dm: DataStoreManagerProtocol
    
    private(set) var models = CurrentValueSubject<[WeatherDataModel], Never>([])
    
    private var disposeBag: Set<AnyCancellable> = []
    
    init(service: ServiceManagerProtocol,
         dataStore: DataStoreManagerProtocol) {
        sm = service
        dm = dataStore

        dm.models.sink { [weak self] models in
            guard let self = self else { return }
            self.models.send(models)
        }
        .store(in: &disposeBag)
    }
    
    private func search(_ text: String) -> AnyPublisher<WeatherModel, APIError> {
        sm.execute(WeatherSearchAPI.GetWeather(query: text))
    }
    
    private func updateData(model: WeatherModel) {
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            await self.dm.saveWeatherData(model: model)
        }
    }
}

extension WeatherSearchService: WeatherSearchServiceProtocol {
    
    func search(_ text: String) {
        if text.isEmpty { return }
        self.search(text)
            .sink { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    self.models.send(self.dm.models.value)
                }
            } receiveValue: { [weak self] model in
                guard let self = self else { return }
                self.updateData(model: model)
            }
            .store(in: &disposeBag)
    }
    
    func getWeatherData() {
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            await self.dm.getWeatherData()
        }
    }
}


fileprivate enum WeatherSearchAPI {
    struct GetWeather: APIGet {
        let path: String = WeatherServiceAPIConstants.path
        let query: String

        var queryParameters: [String: String]? {
            [
                "q": query,
                "APPID": configuration.apiKey,
            ]
        }
    }
}

fileprivate struct GetWeatherQueryParms: Encodable {
    let q: String
    let APPID: String
}

fileprivate enum WeatherServiceAPIConstants {
    static let path = "/data/2.5/weather"
}

// MARK: Test classes

class MockWeatherSearchService: WeatherSearchServiceProtocol {
    
    var models = CurrentValueSubject<[WeatherDataModel], Never>([])
    var searchFuncCalled = false
    var getWeatherDataFuncCalled = false
    
    let sm: ServiceManagerProtocol
    let dm: DataStoreManagerProtocol
        
    init(service: ServiceManagerProtocol,
         dataStore: DataStoreManagerProtocol) {
        sm = service
        dm = dataStore
    }
        
    func search(_ text: String) {
        searchFuncCalled = true
    }
    
    func getWeatherData() {
        getWeatherDataFuncCalled = true
    }
}
