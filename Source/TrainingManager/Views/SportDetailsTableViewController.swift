//
//  SportDetailsTableViewController.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 24/03/2021.
//

import UIKit

class SportDetailsTableViewController: UITableViewController {

    public var actualSport = 0
    let sectionsSpec = [1, 2, 2, 2]    // static size of tableView

    @IBOutlet weak var averageTrainingTime: UILabel!
    
    @IBOutlet weak var weekAverageTrainingNumber: UILabel!
    @IBOutlet weak var weekAverageTrainingTime: UILabel!
    
    @IBOutlet weak var longestTraining: UILabel!
    @IBOutlet weak var trainingStreak: UILabel!
    
    @IBOutlet weak var overallTrainingNumber: UILabel!
    @IBOutlet weak var overallTrainingTime: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = SportType.sportsArray[actualSport].idName
        
        var predicate = NSPredicate()
        
        if (actualSport != 0){
            predicate = NSPredicate(format: "sport = %d", actualSport)
        }
        else{
            predicate = NSPredicate(value: true)
        }
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
        
        longestTraining.text = stats.longestTraining()
        trainingStreak.text = stats.trainingStreak()
        
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
