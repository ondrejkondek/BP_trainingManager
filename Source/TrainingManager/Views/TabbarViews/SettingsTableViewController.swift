//
//  SettingsTableViewController.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 24/02/2021.
//

import UIKit
import MessageUI

class SettingsTableViewController: UITableViewController {
    
    let sectionsSpec = [1, 2, 1, 3]     // static tableView
    
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var navItem: UINavigationItem!
    
    @IBOutlet weak var profileCell: UITableViewCell!
    @IBOutlet weak var contactCell: UITableViewCell!
    @IBOutlet weak var addSiriCell: UITableViewCell!
    @IBOutlet weak var locationCell: UITableViewCell!
    @IBOutlet weak var deleteDataCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barStyle = .black
 
        let name = UserDefaultsManager.shared.ud.value(forKey: "name") as? String
        let surname = UserDefaultsManager.shared.ud.value(forKey: "surname") as? String
        
        profileLabel.text = "\(name ?? "Name") \(surname ?? "Surname")"
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsSpec.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionsSpec[section]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let cell = tableView.indexPath(for: contactCell), cell == indexPath {
            if let url = URL(string: "mailto://xkonde04@stud.fit.vutbr.cz") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                } else {
                    print("Error - unsuccesful opening an email client")
                }
            }
        }
        
        if let cell = tableView.indexPath(for: locationCell), cell == indexPath {
            LocationManager.shared.locationManualPermission(vc: self)
        }

        if let cell = tableView.indexPath(for: deleteDataCell), cell == indexPath {
            
            let alert = UIAlertController(title: "Are you sure to delete all your records?", message: "You cannot undo this action.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                switch action.style{
                case .default:
                    CoreDataManager.shared.deleteAllRecords()
                case .cancel:
                    break
                case .destructive:
                    break
                default:
                    break
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        if let cell = tableView.indexPath(for: profileCell), cell == indexPath {
            
            if CloudKitManager.shared.isiCloudAvailable() {
            
                let alert = UIAlertController(title: "Change your name", message: "Your name and surname are visible in social stats.", preferredStyle: .alert)
                
                alert.addTextField { textField in
                    textField.placeholder = "First Name"
                }
                alert.addTextField { textField in
                    textField.placeholder = "Last Name"
                }
                
                alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { action in
                    switch action.style{
                    case .default:
                        
                        let settings = CoreDataManager.shared.fetchUserSettings()
                        if settings != nil {
                                
                            settings?.name = alert.textFields![0].text
                            settings?.surname = alert.textFields![1].text
                            
                            UserDefaultsManager.shared.ud.setValue(settings?.name, forKey: "name")
                            UserDefaultsManager.shared.ud.setValue(settings?.surname, forKey: "surname")
                            
                            if (CoreDataManager.shared.saveData() != 0){
                                let alert = UIAlertController(title: "Failed", message: "Unable to save changes! Please try again.", preferredStyle: .alert)
                                alert.createOkAlert()
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                            DispatchQueue.main.async {
                                self.profileLabel.text = "\(settings?.name ?? "Name") \(settings?.surname ?? "Surname")"
                            }
                            
                            LaunchManager.shared.makePublicStats()
                        }

                    case .cancel:
                        break
                    case .destructive:
                        break
                    default:
                        break
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)

            }
            else{
                let alert = UIAlertController(title: "Unable to connect", message: "You need to be signed in to your iCloud account.", preferredStyle: .alert)
                alert.createOkAlert()
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                
        if segue.identifier == "siriView" {
            
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            backItem.tintColor = UIColor.white
            self.navItem.backBarButtonItem = backItem
        }
    }

}

