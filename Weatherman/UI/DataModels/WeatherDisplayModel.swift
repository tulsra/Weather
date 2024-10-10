//
//  WeatherDisplayModel.swift
//  Weatherman
//
//  Created by Thulasi Ram Boddu on 8/10/24.
//

import Foundation

struct WeatherDisplayModel: Identifiable {
    var id: UUID = UUID()
    var city: String
    var temperature: String
    var humidity: String
    var analysis: String
    var url: String
    
    init (model: WeatherDataModel) {
        self.city = model.city ?? ""
        self.temperature = "\(Int(model.temp)) °F".capitalized
        self.humidity = "\(Int(model.humidity)) %"
        self.analysis = model.desc ?? ""
        self.url = "https://openweathermap.org/img/wn/\(model.icon ?? "")@2x.png"
    }
}
