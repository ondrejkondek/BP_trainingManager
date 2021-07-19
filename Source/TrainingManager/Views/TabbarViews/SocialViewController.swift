//
//  SocialViewController.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 19/02/2021.
//

import UIKit
import CloudKit

class SocialViewController: UIViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let DB = CKContainer(identifier: "iCloud.TrainingManager").publicCloudDatabase
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sportSelectButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var navItem: UINavigationItem!
    
    var users = [String]()
    var usersIDs = [String]()
    
    var actualSport = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboardWhenTapAway()
        navigationController?.navigationBar.barStyle = .black

        actualSport = UserDefaultsManager.shared.getActualSport()
        sportSelectButton.image = SportType.sportsArray[actualSport].image
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationSportChanged(_ :)), name: Notification.Name("sportChanged"), object: nil)
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        tableView.isHidden = true
    
        // Init fetch for tableView
        fetchItems(predicate: NSPredicate(value: true))
    }
    
    @objc func notificationSportChanged(_ notificationData: NSNotification) {
        let data = notificationData.userInfo
        let sportSelected = data?["sportSelected"] as? Int ?? 0
        actualSport = sportSelected
        sportSelectButton.image = SportType.sportsArray[sportSelected].image
    }
    
    /// Fetch users for tableView and show them into GUI
    /// - Parameter predicate: query for search
    func fetchItems(predicate: NSPredicate){
        
        CloudKitManager.shared.fetchUserStats(predicate: predicate){
            records in

            DispatchQueue.main.async {
                let names = records.compactMap({ $0.value(forKey: "name") as? String})
                let surnames = records.compactMap({ $0.value(forKey: "surname") as? String})
                self.usersIDs = records.compactMap({ $0.value(forKey: "id") as? String})
                self.users.removeAll()
                for (name, surname) in zip(names, surnames) {
                    self.users.append("\(name) \(surname)")
                }
                
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.tableView.isHidden = false
                
                self.tableView.reloadData()
            }
        }
    }
    
    /// unwind back from PublicStats VC
    @IBAction func unwindBackToSocialView(segue: UIStoryboardSegue) {
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let row = tableView.indexPathForSelectedRow?.row
        
        if segue.identifier == "chooseSportFromSocial" {
            let vc = segue.destination as? SportSelectTableViewController
            vc?.fromView = 3
        }
        if segue.identifier == "userStats" {
            let userStats = segue.destination as? PublicStatsViewController
            
            userStats?.title = users[row!]
            userStats?.userID = usersIDs[row!]
            
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            backItem.tintColor = UIColor.white
            self.navItem.backBarButtonItem = backItem
        }
    }
    
}

// MARK: TableView delegate with User names
extension SocialViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "socialCell", for: indexPath) as? SocialCell else {
            fatalError() }
        
        cell.labelName.text = users[indexPath.row]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

}

// MARK: UISearchbar Delegate
extension SocialViewController: UISearchBarDelegate {
    
    /// Make a new query everytime something changes
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        tableView.isHidden = true
        
        users.removeAll()
        usersIDs.removeAll()
        
        let delimiter = " "
        let fullname = searchText.components(separatedBy: delimiter)
        if fullname.count == 1 {
            let predicate = NSPredicate(format: "name BEGINSWITH %@", fullname[0])
            fetchItems(predicate: predicate)
        }
        else if fullname.count == 2 {
            let predicate = NSPredicate(format: "name BEGINSWITH %@ AND surname BEGINSWITH %@", fullname[0], fullname[1])
            fetchItems(predicate: predicate)
        }
    }
    
}
