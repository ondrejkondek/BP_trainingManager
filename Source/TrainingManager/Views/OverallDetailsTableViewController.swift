//
//  OverallDetailsTableViewController.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 24/03/2021.
//

import UIKit

class OverallDetailsTableViewController: UITableViewController {

    public var actualSport = 0
    let sectionsSpec = [1, 2, 3, 2, 2]  // static size of tableView
    
    @IBOutlet weak var averageTrainingTime: UILabel!
    
    @IBOutlet weak var weekAverageTrainingNumber: UILabel!
    @IBOutlet weak var weekAverageTrainingTime: UILabel!
    
    @IBOutlet weak var favoriteSport: UILabel!
    @IBOutlet weak var favoriteSportTrainings: UILabel!
    @IBOutlet weak var favoriteSportTime: UILabel!
    
    @IBOutlet weak var longestTraining: UILabel!
    @IBOutlet weak var bestStreak: UILabel!
    
    @IBOutlet weak var overallTrainingNumber: UILabel!
    @IBOutlet weak var overallTrainingTime: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Overall"

        let predicate = NSPredicate(value: true)
        let records = CoreDataManager.shared.fetchRecords(predicate: predicate) ?? []
        self.setLabels(records: records)
    }
    
    /// Sets the labels (in tableView cells) to specific values
    /// Values are counted in this method thanks to StatisticManager
    /// - Parameter records: array of records from which stats should be made
    func setLabels(records: [Record]){
        
        let stats = StatisticsManager(records: records)
        
        averageTrainingTime.text = stats.averageTrainingTime()
        
        weekAverageTrainingNumber.text = stats.weekAverageTrainingNumber()
        weekAverageTrainingTime.text = stats.weekAverageTrainingTime()
        
        let favSportStats = stats.favouriteSportInfo()
        favoriteSport.text = favSportStats.0
        favoriteSportTrainings.text = favSportStats.1
        favoriteSportTime.text = favSportStats.2
        
        longestTraining.text = stats.longestTraining()
        bestStreak.text = String(UserDefaultsManager.shared.bestStreak(streak: 0))
        
        overallTrainingNumber.text = stats.overallTrainingNumber()
        overallTrainingTime.text = stats.overallTrainingTime()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsSpec.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionsSpec[section]
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
