//
//  LocationViewController.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 19/03/2021.
//

import UIKit
import CoreLocation

class LocationViewController: UIViewController {

    @IBOutlet weak var getLocationButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var fromView = 0
    
    var locations = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboardWhenTapAway()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }
    
    /// Get current location from GPS
    @IBAction func getLocation(_ sender: Any) {
        
        // user permission
        if LocationManager.shared.askPermissionManually {
            LocationManager.shared.locationManualPermission(vc: self)
        }

        LocationManager.shared.getUserLocation() {
            location in

            let geocoder = CLGeocoder()

            geocoder.reverseGeocodeLocation(location, completionHandler: {
                placemarks, error in
                if error == nil {
                    
                    DispatchQueue.main.async {
                        if let placemarks = placemarks {
                            
                            self.locations.removeAll()
                            let location = self.getStringFromPlacemark(placemarks[0])
                            self.locations.append(location)
                            self.tableView.reloadData()
                        }
                    }
                }
                else{
                    // an error ocurred during geocodding
                    DispatchQueue.main.async {
                        self.locations.removeAll()
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }
    
    /// - Parameter placemark: CLPlacemark
    /// - Returns: string with the address of placemark
    func getStringFromPlacemark(_ placemark: CLPlacemark) -> String {
        
        var string = ""
        var first = true
        
        if let city = placemark.locality {
            first = false
            string += String(city)
        }
        if let street = placemark.thoroughfare {
            string += ", " + String(street)
        }
        if let streetInfo = placemark.subThoroughfare {
            string += ", " + String(streetInfo)
        }
        if let country = placemark.country {
            if first {
                string += String(country)
            }
            else{
                string += ", " + String(country)
            }
        }
        
        return string
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let row = tableView.indexPathForSelectedRow?.row
        
        if segue.identifier == "unwindBackToRecordView" {
            let vc = segue.destination as? RecordViewController
            vc?.locationButton.setTitle(locations[row!], for: .normal)
        }
        if segue.identifier == "unwindBackToAddRecordView" {
            let vc = segue.destination as? AddRecordViewController
            vc?.locationButton.setTitle(locations[row!], for: .normal)
        }
        if segue.identifier == "unwindBackToDetailsRecordView" {
            let vc = segue.destination as? DetailsRecordViewController
            vc?.locationButton.setTitle(locations[row!], for: .normal)
        }
    }
}

// MARK: Table View Delegate, Data Source
extension LocationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "socialCell", for: indexPath) as? SocialCell else {
            fatalError() }
        
        cell.labelName.text = locations[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if fromView == 0{
            self.performSegue(withIdentifier: "unwindBackToRecordView", sender: self)
        }
        else if fromView == 1{
            self.performSegue(withIdentifier: "unwindBackToAddRecordView", sender: self)
        }
        else{
            self.performSegue(withIdentifier: "unwindBackToDetailsRecordView", sender: self)
        }
    }
    
}

// MARK: SearchBar delegate
extension LocationViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       
        self.locations.removeAll()
        self.tableView.reloadData()
        
        LocationManager.shared.findLocations(query: searchText) {
            placemarks in
            
            if placemarks.isEmpty {
                return
            }
            
            DispatchQueue.main.async {
                let location = self.getStringFromPlacemark(placemarks[0])
                self.locations.append(location)
                self.tableView.reloadData()
            }
        }
    }

}
