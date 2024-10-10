//
//  LocationManager.swift
//  Weatherman
//
//  Created by Thulasi Ram Boddu on 8/22/24.
//

import Combine
import CoreLocation
import Foundation

protocol LocationManagerProtocol {
    var location: PassthroughSubject<String, Never>{ get }
    func getLocationDetails()
}

final class LocationManager: NSObject {
    
    private var lm = CLLocationManager()
    private(set) var location = PassthroughSubject<String, Never>()
    
    override init() {
        super.init()
        lm.delegate = self
    }
}

extension LocationManager: LocationManagerProtocol {
    func getLocationDetails() {
        if lm.authorizationStatus == .notDetermined {
            lm.requestWhenInUseAuthorization()
        } else {
            lm.requestLocation()
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            switch manager.authorizationStatus {
            case .authorizedWhenInUse:
                //Location services are authorized
                lm.requestLocation()
            case .restricted: break
                //Location services are NOT authorized
            case .denied: break
                //Location services are NOT authorized
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
            default:
                break
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            // Insert code to handle location updates
            if let loc = locations.first {
                CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)) { [weak self] placemarks, _ in
                    if let self = self, let placemark = placemarks?.first {
                        self.location.send("\(placemark.locality ?? ""), \(placemark.country ?? "")")
                    }
                }
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("error: \(error.localizedDescription)")
        }
}

// MARK: Test classes

final class MockLocationManager: LocationManagerProtocol {
    var location = PassthroughSubject<String, Never>()
    var getLocationDetailsFuncCalled = false
    func getLocationDetails() {
        getLocationDetailsFuncCalled = true
    }
}
