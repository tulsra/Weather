//
//  RootViewModel.swift
//  Weatherman
//
//  Created by Thulasi Ram Boddu on 10/9/24.
//

import Combine
import Foundation
import Observation

@Observable
final class RootViewModel {
    
    @ObservationIgnored private var disposeBag: Set<AnyCancellable> = []
    @ObservationIgnored private let sm: WeatherSearchServiceProtocol
    @ObservationIgnored private let lm: LocationManagerProtocol
    
    @Published @ObservationIgnored var searchText: String = ""
    var models: [WeatherDisplayModel] = []
    var isLoading: Bool = false
    
    init(sm: WeatherSearchServiceProtocol, lm: LocationManagerProtocol) {
        self.sm = sm
        self.lm = lm
        
        isLoading = true
        
        $searchText
        #if TEST
            .filter { $0 != "" }
        #else
            .debounce(for: 1, scheduler: DispatchQueue.main)
            .filter { $0 != "" }
        #endif
            .sink(receiveValue: { [weak self] text in
                guard let self = self else { return }
                if text.count > 2 {
                    self.isLoading = true
                    self.sm.search(text)
                } else {
                    self.isLoading = false
                }
            })
            .store(in: &disposeBag)
        
        sm.models
            .receive(on: RunLoop.main)
            .map { $0.map { WeatherDisplayModel(model: $0)}}
            .sink { [weak self] models in
                guard let self = self else { return }
                self.models = models
                self.isLoading = false
            }
            .store(in: &disposeBag)
        
        lm.location
            .receive(on: RunLoop.main)
            .sink { [weak self] location in
                guard let self = self else { return }
                self.sm.search(location)
            }
            .store(in: &disposeBag)
    }
    
    func getWeatherData() {
        sm.getWeatherData()
    }
    
    func getLocationDetails() {
        LocationManager().getLocationDetails()
    }
    
    func testFunc() {
        // Test line develop - 10
        // Test line develop - 20
        // Test line develop - 30
        // Test line develop - 40
        // Test line develop - 50
    }
}
