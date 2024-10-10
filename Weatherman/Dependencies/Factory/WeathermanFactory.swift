//
//  WeathermanFactory.swift
//  Weatherman
//
//  Created by Thulasi Ram Boddu on 10/9/24.
//

import Foundation

protocol WeathermanFactoryProtocol {
    func rootCoordinator() -> RootCoordinatorProtocol
}

final class WeathermanFactory {
    private var sm: ServiceManagerProtocol = ServiceManager()
    private var dm: DataStoreManagerProtocol = DataStoreManager()
    private var lm: LocationManagerProtocol = LocationManager()
    static let shared: WeathermanFactory = WeathermanFactory()
    
    private init() {}
}

extension WeathermanFactory: WeathermanFactoryProtocol {
    func rootCoordinator() -> RootCoordinatorProtocol {
        let rootCoordinator = RootCoordinator(sm: sm, dm: dm, lm: lm)
        return rootCoordinator
    }
}

// MARK: Test classes

final class MockWeathermanFactory: WeathermanFactoryProtocol {
    
    var sm: ServiceManagerProtocol = MockServiceManager()
    var dm: DataStoreManagerProtocol = MockDataStoreManager()
    var lm: LocationManagerProtocol = MockLocationManager()
    static let shared: MockWeathermanFactory = MockWeathermanFactory()
    
    private init() {}
    
    func rootCoordinator() -> RootCoordinatorProtocol {
        return MockRootCoordinator(sm: sm, dm: dm, lm:lm)
    }
}
