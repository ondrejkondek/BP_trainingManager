//
//  PublicStatsViewController.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 04/03/2021.
//

import UIKit
import Charts
import CloudKit

class PublicStatsViewController: UIViewController {

    public var userID: String?
    let DB = CKContainer(identifier: "iCloud.TrainingManager").publicCloudDatabase
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var searchedUserNameLabel: UILabel!
    @IBOutlet weak var searchedUserOverallLabel: UILabel!
    @IBOutlet weak var searchedUserSportImage: UIImageView!
    @IBOutlet weak var searchedUserSportLabel: UILabel!
    @IBOutlet weak var meUserOverallLabel: UILabel!
    @IBOutlet weak var meUserSportLabel: UILabel!
    @IBOutlet weak var meUserSportImage: UIImageView!
    
    @IBOutlet weak var meLabel: UILabel!
    @IBOutlet weak var overallLabel: UILabel!
    @IBOutlet weak var favouriteSportLabel: UILabel!
    
    var searchedUser: UserStats = UserStats()
    var meUser: UserStats = UserStats()
    var unit = 0
    
    var lastUpdateDaysAgo = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboardWhenTapAway()
        
        activityIndicator.hidesWhenStopped = true
        infoButton.isHidden = true
        self.meLabel.isHidden = true
        self.favouriteSportLabel.isHidden = true
        self.overallLabel.isHidden = true
        
        barChart.setStaticSettings(vc: "Public")
        
        activityIndicator.startAnimating()
        self.barChart.animate(xAxisDuration: 0.3, yAxisDuration: 0.7)
   }
    
    override func viewWillAppear(_ animated: Bool) {
        
        createBarChart()
    }
    
    @IBAction func showInfo(_ sender: Any) {

        let alert = UIAlertController(title: "Outdated statistics", message: "\nLast update: \(self.lastUpdateDaysAgo) days ago", preferredStyle: .alert)
        alert.createOkAlert()
        self.present(alert, animated: true, completion: nil)
    }
    
    /// Fetch UserStats
    /// - Parameter userID: query for fetch
    /// - Parameter completion: able to stay  in the sync process when calling
    func fetchUserStats(userID: String, completion: @escaping (() -> Void)){
        
        let myID = UserDefaultsManager.shared.ud.value(forKey: "id") as? String
        let query = CKQuery(recordType: "UserStats", predicate: NSPredicate(format: "id IN %@", [userID, myID]))
        DB.perform(query, inZoneWith: nil, completionHandler: { records, error in
            guard let records = records, error == nil else{
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.barChart.noDataText = "Unable to connect"
                }
                return
            }
            DispatchQueue.main.async {
                let ids = records.compactMap({ $0.value(forKey: "id") as? String})
                let favSports = records.compactMap({ $0.value(forKey: "favSport") as? Int})
                let timeFavSports = records.compactMap({ $0.value(forKey: "timeOfFavSport") as? Int})
                let timeSports = records.compactMap({ $0.value(forKey: "timeOfAllSports") as? Int})
                let lastUpdates = records.compactMap({ $0.value(forKey: "lastUpdate") as? Date})
                let names = records.compactMap({ $0.value(forKey: "name") as? String})
                
                // if comparison between ME and ME
                if ids.count == 1, myID == userID{
                    self.meUser = self.meUser.setUserInfo(favSport: favSports.first!, timeOfFavSport: timeFavSports.first!, timeOfAllSports: timeSports.first!, lastUpdate: lastUpdates.first!, name: "Me")
                    self.searchedUser = self.searchedUser.setUserInfo(favSport: favSports.first!, timeOfFavSport: timeFavSports.first!, timeOfAllSports: timeSports.first!, lastUpdate: lastUpdates.first!, name: "Me")
                }
                // if comparison between ME and Searched User
                else if ids.count != 1, myID != userID{
                    for (idx, id) in ids.enumerated() {
                        if id == myID {
                            self.meUser = self.meUser.setUserInfo(favSport: favSports[idx], timeOfFavSport: timeFavSports[idx], timeOfAllSports: timeSports[idx], lastUpdate: lastUpdates[idx], name: "Me")
                        }
                        else {
                            self.searchedUser = self.searchedUser.setUserInfo(favSport: favSports[idx], timeOfFavSport: timeFavSports[idx], timeOfAllSports: timeSports[idx], lastUpdate: lastUpdates[idx], name: names[idx])
                        }
                    }
                }
                // Problem - not existing MY userID
                else if ids.count == 1, myID != userID{
                    self.meUser = self.meUser.setUserInfo(favSport: 0, timeOfFavSport: 0, timeOfAllSports: 0, lastUpdate: Date(), name: "Me")
                    self.searchedUser = self.searchedUser.setUserInfo(favSport: favSports.first!, timeOfFavSport: timeFavSports.first!, timeOfAllSports: timeSports.first!, lastUpdate: lastUpdates.first!, name: names.first!)
                }
                // Problem - not existing userIDs
                else{
                    self.activityIndicator.stopAnimating()
                    self.barChart.noDataText = "Unable to connect"
                    return
                }
                completion()
            }
        })
    }
}

// MARK: Handling BarChart and its data + Handling table with statistics and its data
extension PublicStatsViewController {
        
    /// This code is highly inspired by the post on stackoverflow.com
    /// Authors' nicknames: Rajan Twanabashu
    /// Date: answered Feb 2 '17 at 11:26
    /// Source: https://stackoverflow.com/questions/35294076/how-to-make-a-grouped-barchart-with-ios-charts
    ///
    /// Fetches the needed data and creates the grouped barChart
    /// Fill the table with data 
    func createBarChart() {
        
        fetchUserStats(userID: self.userID ?? "") {
            
            let daysAgo = self.searchedUser.lastUpdate?.howManyDaysAgo() ?? 0
            if  daysAgo > 1 {
                self.infoButton.isHidden = false
                self.lastUpdateDaysAgo = daysAgo
            }
            if daysAgo > 7 {
                self.activityIndicator.stopAnimating()
                self.barChart.noDataText = "No User Activity This Week"
                return
            }
            
            self.meLabel.isHidden = false
            self.favouriteSportLabel.isHidden = false
            self.overallLabel.isHidden = false
            
            let stats = self.setUnitForTime()
            self.barChart.setYlabels(unit: self.unit)
            
            let barChartDataSet = self.barChart.prepareDataSetForGroupBarChart(stats.0,
                                                                          stats.1,
                                                                          stats.2,
                                                                          stats.3)
            
            let data = BarChartData(dataSets: barChartDataSet)

            data.barWidth = 0.3
            self.barChart.xAxis.axisMinimum = 0.0
            let groupWidth = data.groupWidth(groupSpace: 0.3, barSpace: 0.05)
            self.barChart.xAxis.axisMaximum = 0.0 + groupWidth * 2.0
            data.groupBars(fromX: 0.0, groupSpace: 0.3, barSpace: 0.05)

            self.barChart.data = data
            
            self.barChart.setXlabels(interval: "public", labels: ["Me", self.searchedUser.name ?? ""])
            
            self.setStatsTable()
            
            self.activityIndicator.stopAnimating()
            self.barChart.notifyDataSetChanged()
        }
    }
    
    /// Sets the correct unit based on maximum value in the data
    /// - Returns: tupple of 4 double values - values were divided by const based on values
    func setUnitForTime() -> (Double, Double, Double, Double){
        
        self.unit = 1 // minutes
        
        if (self.meUser.timeOfAllSports ?? 0 > 80 * 60) || (self.searchedUser.timeOfAllSports ?? 0 > 80 * 60){
            self.unit = 0 // hours
        }
            
        var const = 0.0
        if self.unit == 0 {
            const = 3600.0
        }
        else{
            const = 60.0
        }
        
        let meUserTimeOfFavSport = Double(self.meUser.timeOfFavSport ?? 0) / const
        let meUserTimeOfAllSports = Double(self.meUser.timeOfAllSports ?? 0) / const
        let searchedUserTimeOfFavSport = Double(self.searchedUser.timeOfFavSport ?? 0) / const
        let searchedUserTimeOfAllSports = Double(self.searchedUser.timeOfAllSports ?? 0) / const
        
        return(meUserTimeOfFavSport, meUserTimeOfAllSports, searchedUserTimeOfFavSport, searchedUserTimeOfAllSports)
    }
    
    /// Sets the text in labels of the table in VC
    func setStatsTable(){
        
        searchedUserNameLabel.text = self.searchedUser.name
        searchedUserOverallLabel.text = Time().getTimeFromSeconds(self.searchedUser.timeOfAllSports!, minretval: "minutes")
        searchedUserSportImage.image = SportType.sportsArray[self.searchedUser.favSport ?? 0].image
        searchedUserSportLabel.text = Time().getTimeFromSeconds(self.searchedUser.timeOfFavSport!, minretval: "minutes")
        
        meUserOverallLabel.text = Time().getTimeFromSeconds(self.meUser.timeOfAllSports!, minretval: "minutes")
        meUserSportLabel.text = Time().getTimeFromSeconds(self.meUser.timeOfFavSport!, minretval: "minutes")
        meUserSportImage.image = SportType.sportsArray[self.meUser.favSport ?? 0].image
    }
    
}


