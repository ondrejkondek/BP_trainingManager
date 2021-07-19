//
//  CalendarViewController.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 26/02/2021.
//

import UIKit
import FSCalendar
import CoreData

class CalendarViewController: UIViewController {
    
    let context = getMOC()
    
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var sportSelectButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectedDate: UILabel!
    
    var dateToRemove: Date?
    var selectedRecord: Record?     // selected / tapped in tableView
    var records = [Record]()
    var dayRecords = [Record]()     // records of the specific day
    var recordDates = [Date]()      // dates of all records
    var actualSport = 0
    
    /// Initialization of FRC for Calendar - event dots
    lazy var FRCCalendar: NSFetchedResultsController<Record> = {
        
        let fetchRequest: NSFetchRequest<Record> = Record.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        let FRC = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: self.context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        return FRC
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barStyle = .black
        
        calendarView.delegate = self
        calendarView.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = UIColor.white
        FRCCalendar.delegate = self
        selectedDate.isHidden = true
        
        actualSport = UserDefaultsManager.shared.getActualSport()
        sportSelectButton.image = SportType.sportsArray[actualSport].image
        NotificationCenter.default.addObserver(self, selector: #selector(notificationSportChanged(_ :)),
                                               name: Notification.Name("sportChanged"), object: nil)
        
        initCalendarWithFetch()
    }
    
    /// Fill calendar with data - event dots
    /// Based on selected sport
    func initCalendarWithFetch() {
        
        if (actualSport != 0){
            FRCCalendar.fetchRequest.predicate = NSPredicate(format: "sport = %d", actualSport)
        }
        else{
            FRCCalendar.fetchRequest.predicate = NSPredicate(value: true)
        }
        
        do {
            try FRCCalendar.performFetch()
        } catch {
            print("Unable to FETCH")
        }
        
        let records = FRCCalendar.fetchedObjects
        self.recordDates = records!.compactMap({ $0.value(forKey: "date") as? Date})
        self.calendarView.reloadData()
    }
    
    @objc func notificationSportChanged(_ notificationData: NSNotification) {
        let data = notificationData.userInfo
        let sportSelected = data?["sportSelected"] as? Int ?? 0
        actualSport = sportSelected
        sportSelectButton.image = SportType.sportsArray[sportSelected].image
        
        FRCCalendar.fetchRequest.predicate = NSPredicate(format: "sport = %d", actualSport)
        initCalendarWithFetch()
        self.dayRecords.removeAll()
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chooseSportFromCalendar" {
            let vc = segue.destination as? SportSelectTableViewController
            vc?.fromView = 1
        }
        else if segue.identifier == "showRecordDetail" {
            let vc = segue.destination as? DetailsRecordViewController
            vc?.record = selectedRecord
            dateToRemove = selectedRecord?.date
            vc?.fromView = 0
        }
    }
    
    @IBAction func unwindBackToCalendarView(segue: UIStoryboardSegue) {
        
        initCalendarWithFetch()
        self.dayRecords.removeAll()
        tableView.reloadData()
    }
    
    @IBAction func unwindBackToCalendarViewFromDetailsRecordView(segue: UIStoryboardSegue) {

        // fetch data for specific Date and show it to table
        if let date = dateToRemove {
            self.dayRecords = CoreDataManager.shared.fetchRecordsForDay(sport: actualSport, date: date) ?? []
            self.tableView.reloadData()
        }
    }
}

// MARK: CALENDAR
extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {

        // fetch data for specific Date and show it to table
        self.dayRecords = CoreDataManager.shared.fetchRecordsForDay(sport: actualSport, date: date) ?? []
        self.tableView.reloadData()
        self.selectedDate.isHidden = false
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd MMMM yyyy"
        let time = dateFormatterPrint.string(from: date)
        self.selectedDate.text = time
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        
        if self.recordDates.contains(date) {
            return 1
        }
        return 0
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate.isHidden = false
    }
}

// MARK: TABLE VIEW FOR RECORDS OF CHOSEN DAY
extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dayRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "calendarCell", for: indexPath) as? CalendarCell else {
            fatalError() }
        
        cell.calendarCellModel = dayRecords[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        self.selectedRecord = self.dayRecords[indexPath.row]
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // deleting on main context because on backcontext there were just IDs
            self.context.delete(dayRecords[indexPath.row])
            dayRecords.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        
            if (CoreDataManager.shared.saveData() != 0){
                let alert = UIAlertController(title: "Failed", message: "Unable to save changes! Please try again.", preferredStyle: .alert)
                alert.createOkAlert()
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

}

// MARK: FETCHED RESULTS CONTROLLER
extension CalendarViewController: NSFetchedResultsControllerDelegate {
        
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .update:
            fallthrough
        case .insert:
            fallthrough
        case .delete:
            DispatchQueue.main.async {
                let records = self.FRCCalendar.fetchedObjects
                self.recordDates = records!.compactMap({ $0.value(forKey: "date") as? Date})
                self.calendarView.reloadData()
            }
        default:
            break
        }
    }
    
}
