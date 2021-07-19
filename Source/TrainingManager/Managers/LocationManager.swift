//
//  LocationManager.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 19/03/2021.
//

import UIKit
import CoreLocation

/// Class managing Location information, getter of a user actual location
class LocationManager: NSObject {
    
    static let shared = LocationManager()
    
    let manager = CLLocationManager()
    
    var completion: ((CLLocation) -> Void)?
    var askPermissionManually = false
    
    /// Get user Location - Init method
    /// - Parameter completion: contains array of Locations, where user is located
    func getUserLocation(completion: @escaping ((CLLocation) -> Void)) {
        self.completion = completion
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    /// Get location based on query
    /// Inspired by:
    /// https://developer.apple.com/documentation/corelocation/converting_between_coordinates_and_user-friendly_place_names
    /// - Parameter query: query for the search
    /// - Parameter completion: contains array of placemarks
    func findLocations(query: String, completion: @escaping  (([CLPlacemark]) -> Void)){
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(query) { placemarks, error in
            
            if let placemarks = placemarks, error == nil {
                completion(placemarks)
            }
            else{
                completion([])
                return
            }
        }
    }
    
    /// Manual setting of location permission - showing the UIAlert
    /// - Parameter vc: VC of the parent, on which UIAlert will be pushed
    func locationManualPermission(vc: UIViewController) {
        // Initialise a pop up for using later
        let alertController = UIAlertController(title: "Allow Tajmer to use your location?", message: "Please go to Settings and turn on the permissions", preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: "Settings", style: .default) { action in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
             }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)

        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)

        vc.present(alertController, animated: true, completion: nil)
    }
}

// MARK: Delegates of location manager
extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else{
            return
        }
        completion?(location)
        manager.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        if (manager.authorizationStatus == .denied){
            askPermissionManually = true
        }
        else{
            askPermissionManually = false
        }
    }
}
