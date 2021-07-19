//
//  BarChartViewController.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 23/03/2021.
//

import UIKit
import Charts

class BarChartViewController: UIViewController {

    var actualSport = 0
    var unit = 0   // 0 hours, 1 minutes
    var records = [Record]()
    var dateToRemove: Date?
    var selectedRecord: Record?
    var selectedInterval: Int?
    
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var intervalLabel: UILabel!
    @IBOutlet weak var selectedDate: UILabel!
    var interval = Interval(actualInterval: 3)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        barChart.setStaticSettings(vc: "Stats")
        barChart.dragEnabled = true
        barChart.highlightPerTapEnabled = true
        selectedDate.isHidden = true
        
        barChart.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = UIColor.white
        
        self.title = SportType.sportsArray[actualSport].idName
        
        backgroundView.layer.cornerRadius = 10
        
        interval = Interval(actualInterval: selectedInterval ?? 3)
        let text = self.interval.getInterval().0
        intervalLabel.text = text
        
        setGestures()
        initBarChartWithFetch()
    }

    @IBAction func zoomIn(_ sender: Any) {
        barChart.zoomIn()
    }
    
    @IBAction func zoomOut(_ sender: Any) {
        barChart.zoomOut()
    }
    
    /// Fill BarChart with data
    /// Sets the text of timeLabel
    func initBarChartWithFetch(){
        
        var predicate = NSPredicate()
        
        if (actualSport != 0){
            predicate = NSPredicate(format: "sport = %d AND date <= %@ AND date >= %@", actualSport, Date() as NSDate, Date().getXdaysAgoDate(daysAgo: self.interval.getInterval().1) as NSDate)
        }
        else{
            predicate = NSPredicate(format: "date <= %@ AND date >= %@", Date() as NSDate, Date().getXdaysAgoDate(daysAgo: self.interval.getInterval().1) as NSDate)
        }

        let records = CoreDataManager.shared.fetchRecords(predicate: predicate) ?? []
        let text = self.barChart.updateBarChart(records: records,
                                                interval: self.interval.getInterval().0,
                                                days: self.interval.getInterval().1)
        self.timeLabel.text = text
          
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRecordDetail2" {
            let vc = segue.destination as? DetailsRecordViewController
            vc?.record = selectedRecord
            dateToRemove = selectedRecord?.date
            vc?.fromView = 1
        }
    }
    
    /// Unwind back from DetailsRecord VC
    @IBAction func unwindBackToBarChartViewFromDetailsRecordView(segue: UIStoryboardSegue) {

        // fetch data for specific Date and show it to table
        if let date = dateToRemove {
            self.records = CoreDataManager.shared.fetchRecordsForDay(sport: actualSport, date: date) ?? []
            self.tableView.reloadData()
            self.initBarChartWithFetch()
        }
    }

}

// MARK: Handling the "interval" buttons and gestures
extension BarChartViewController {
    
    @IBAction func previous(_ sender: Any) {
        self.interval.previous()
        let text = self.interval.getInterval().0
        intervalLabel.text = text
        initBarChartWithFetch()
    }
    
    @IBAction func next(_ sender: Any) {
        self.interval.next()
        let text = self.interval.getInterval().0
        intervalLabel.text = text
        initBarChartWithFetch()
    }
    
    @objc func swipeRecognizerLeft(_ gesture: UISwipeGestureRecognizer){
        next(self)
    }
    @objc func swipeRecognizerRight(_ gesture: UISwipeGestureRecognizer){
        previous(self)
    }
    
    /// Setting different gestures for next/back buttons that are handling intervals for charts
    func setGestures(){
        
        let gestureRecognizerLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeRecognizerLeft(_:)))
        gestureRecognizerLeft.numberOfTouchesRequired = 1
        gestureRecognizerLeft.direction = .left
        intervalLabel.addGestureRecognizer(gestureRecognizerLeft)
        
        let gestureRecognizerRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeRecognizerRight(_:)))
        gestureRecognizerRight.numberOfTouchesRequired = 1
        gestureRecognizerRight.direction = .right
        intervalLabel.addGestureRecognizer(gestureRecognizerRight)
    }
}

// MARK: ChartView Delegate - handling user interactions with barchart
extension BarChartViewController: ChartViewDelegate {
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
        let days = interval.getInterval().1
        let dayNumber = days - Int(entry.x)
        
        let day = Date().getXdaysAgoDate(daysAgo: dayNumber)
        
        selectedDate.isHidden = false
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd MMMM yyyy"
        let time = dateFormatterPrint.string(from: day)
        self.selectedDate.text = time
        
        self.records = CoreDataManager.shared.fetchRecordsForDay(sport: actualSport, date: day) ?? []
        self.tableView.reloadData()
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        selectedDate.isHidden = true
    }
}

// MARK: Table View Delegate, Data source
extension BarChartViewController: UITableViewDelegate, UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "calendarCell", for: indexPath) as? CalendarCell else {
            fatalError() }
        
        cell.calendarCellModel = records[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        self.selectedRecord = self.records[indexPath.row]
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // deleting on main context
            CoreDataManager.shared.context.delete(records[indexPath.row])
            records.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        
            if (CoreDataManager.shared.saveData() != 0){
                let alert = UIAlertController(title: "Failed", message: "Unable to save changes! Please try again.", preferredStyle: .alert)
                alert.createOkAlert()
                self.present(alert, animated: true, completion: nil)
            }
            barChart.notifyDataSetChanged()
        }
    }
}
