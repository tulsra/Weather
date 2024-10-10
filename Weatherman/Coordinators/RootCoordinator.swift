//
//  RootCoordinator.swift
//  Weatherman
//
//  Created by Thulasi Ram Boddu on 10/9/24.
//

import Foundation

protocol RootCoordinatorProtocol {
    func rootView() -> RootView
}

final class RootCoordinator {
    private let sm: ServiceManagerProtocol
    private let dm: DataStoreManagerProtocol
    private let lm: LocationManagerProtocol
    
    init(sm: ServiceManagerProtocol, dm: DataStoreManagerProtocol, lm: LocationManagerProtocol) {
        self.sm = sm
        self.dm = dm
        self.lm = lm
    }
}

extension RootCoordinator: RootCoordinatorProtocol {
    func rootView() -> RootView {
        let ws = WeatherSearchService(service: sm, dataStore: dm)
        let vm = RootViewModel(sm: ws, lm: lm)
        return RootView(vm: vm)
    }
}

// MARK: - Test classes

final class MockRootCoordinator: RootCoordinatorProtocol {
    var rootViewCalled = false
    var sm: ServiceManagerProtocol
    var dm: DataStoreManagerProtocol
    var lm: LocationManagerProtocol
    init(sm: ServiceManagerProtocol, dm: DataStoreManagerProtocol, lm: LocationManagerProtocol) {
        self.sm = sm
        self.dm = dm
        self.lm = lm
    }
    
    func rootView() -> RootView {
        rootViewCalled = true
        let ws = MockWeatherSearchService(service: sm, dataStore: dm)
        let vm = RootViewModel(sm: ws, lm: lm)
        return RootView(vm: vm)
    }
}
