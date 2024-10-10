//
//  DataStorageManager.swift
//  Weatherman
//
//  Created by Thulasi Ram Boddu on 8/9/24.
//

import CoreData
import Combine
import Foundation

protocol DataStoreManagerProtocol {
    func getWeatherData() async
    func saveWeatherData(model: WeatherModel) async
    var models: CurrentValueSubject<[WeatherDataModel], Never>{ get }
}

final class DataStoreManager {
    private let container: NSPersistentContainer
    private(set) var models = CurrentValueSubject<[WeatherDataModel], Never>([])
    
    init() {
        container = NSPersistentContainer(name:"WeatherCoreDataStore")
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.loadPersistentStores { description, error in
            if let error = error {
                print("ERROR on Coredata!! \(error.localizedDescription)")
            } else {
                print("SUCCESS!!")
            }
        }
    }
}

extension DataStoreManager: DataStoreManagerProtocol {
    func getWeatherData() async {
        let request = NSFetchRequest<WeatherDataModel>(entityName: "WeatherDataModel")
        do {
            let models = try container.viewContext.fetch(request)
            self.models.send(models)
        } catch let error {
            print("\(error.localizedDescription)")
        }
    }
    
    func saveWeatherData(model: WeatherModel) async {
        let dataModel = WeatherDataModel(context: container.viewContext)
        dataModel.city = model.name
        dataModel.humidity = model.main.humidity
        dataModel.temp = model.main.temp
        dataModel.title = model.weather.first?.main
        dataModel.desc = model.weather.first?.description
        dataModel.icon = model.weather.first?.icon
        do {
            try container.viewContext.save()
            await getWeatherData()
        } catch let error {
            print("\(error.localizedDescription)")
        }
    }
}

// MARK: Test classes

final class MockDataStoreManager: DataStoreManagerProtocol {
    var models = CurrentValueSubject<[WeatherDataModel], Never>([])
    var getWeatherDataFuncCalled = false
    var saveWeatherDataFuncCalled = false
    func getWeatherData() async {
        getWeatherDataFuncCalled = true
    }
    
    func saveWeatherData(model: WeatherModel) async {
        saveWeatherDataFuncCalled = true
    }
}
