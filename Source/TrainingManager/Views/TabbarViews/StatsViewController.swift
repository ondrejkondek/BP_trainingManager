//
//  StatsViewController.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 18/02/2021.
//

import UIKit
import CoreData
import Charts

/// - Returns: MOC of the app
func getMOC() -> NSManagedObjectContext {

     if Thread.current.isMainThread {
         return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
     } else {
         return DispatchQueue.main.sync {
             return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
         }
     }
}

/// - Returns: Persistent container of the app
func getPersistentContainer() -> NSPersistentCloudKitContainer {

    if Thread.current.isMainThread {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    } else {
        return DispatchQueue.main.sync {
            return (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        }
    }
}

class StatsViewController: UIViewController {
    
    var unit = 0 // hours: 0 minutes: 1
    public var actualSport = 0
    
    let context = getMOC()
    
    @IBOutlet weak var sportSelectButton: UIBarButtonItem!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var streakView: UIView!
    @IBOutlet weak var streakNumber: UILabel!
    
    // Current sport stats UIView
    @IBOutlet weak var currentSportStats: UIView!  // CSS
    @IBOutlet weak var CSStimeLabel: UILabel!
    @IBOutlet weak var CSSintervalLabel: UILabel!
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var CSSdetailInfo: UIView!
    // interval specifying number of days to be shown
    var CSSinterval = Interval(actualInterval: 3)
    
    // Overall
    @IBOutlet weak var overallStats: UIView!
    @IBOutlet weak var OSintervalLabel: UILabel!
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var OSdetailInfo: UIView!
    // interval specifying number of days to be shown
    var OSinterval = Interval(actualInterval: 2)
    
    /// initializing FRC for Stats barChart
    lazy var FRCStats: NSFetchedResultsController<Record> = {
        
        let fetchRequest: NSFetchRequest<Record> = Record.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        let FRC = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        return FRC
    }()
    
    /// initializing FRC for Stats pieChart
    lazy var FRCPieChart: NSFetchedResultsController<Record> = {
        
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
        
        actualSport = UserDefaultsManager.shared.getActualSport()
        sportSelectButton.image = SportType.sportsArray[actualSport].image

        FRCStats.delegate = self
        FRCPieChart.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationSportChanged(_ :)), name: Notification.Name("sportChanged"), object: nil)
        
        barChart.setStaticSettings(vc: "Stats")
        pieChart.setStaticSettings()
        setGestures()
        let number = UserDefaultsManager.shared.controlStreak()
        streakNumber.text = String(number)
        
        // setting a radius of all "cells"
        currentSportStats.layer.cornerRadius = 5
        CSSdetailInfo.layer.cornerRadius = 5
        streakView.layer.cornerRadius = 5
        overallStats.layer.cornerRadius = 5
        OSdetailInfo.layer.cornerRadius = 5
        
        initBarChartWithFetch()
        initPieChartWithFetch()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // this part has to be here or the alert about iCloud permissions is presented in background
        if (UserDefaultsManager.shared.isFirstLaunch() == true){
            
            LaunchManager.shared.firstLaunchSetAccount()
                
            initBarChartWithFetch()
            initPieChartWithFetch()
        }
        else{
            LaunchManager.shared.updatePublicStats()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        /// Sets the back button in navigation to "Back"
        func setBackButton(){
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            backItem.tintColor = UIColor.white
            self.navItem.backBarButtonItem = backItem
        }
        
        if segue.identifier == "chooseSportFromStats" {
            let vc = segue.destination as? SportSelectTableViewController
            vc?.fromView = 0
        }
        else if (segue.identifier == "showBarChartView"){
            let vc = segue.destination as? BarChartViewController
            vc?.actualSport = actualSport
            vc?.selectedInterval = CSSinterval.actualInterval
            setBackButton()
        }
        else if (segue.identifier == "showSportDetails"){
            let vc = segue.destination as? SportDetailsTableViewController
            vc?.actualSport = actualSport
            setBackButton()
        }
        else if (segue.identifier == "showOverallDetails"){
            let vc = segue.destination as? SportDetailsTableViewController
            vc?.actualSport = actualSport
            setBackButton()
        }
    }
    
    @IBAction func unwindBackToStatsView(segue: UIStoryboardSegue) {
        initBarChartWithFetch()
    }
    
}

// MARK: Handling the "interval" buttons and gestures
extension StatsViewController {
    
    /// Right (next) button setting the interval for Current sport statistics barChart
    @IBAction func CSSnext(_ sender: Any) {
        self.CSSinterval.next()
        let text = self.CSSinterval.getInterval().0
        CSSintervalLabel.text = text
        initBarChartWithFetch()
    }
    
    /// Left (previous) button setting the interval for Current sport statistics barChart
    @IBAction func CSSprevious(_ sender: Any) {
        self.CSSinterval.previous()
        let text = self.CSSinterval.getInterval().0
        CSSintervalLabel.text = text
        initBarChartWithFetch()
    }
    
    /// Right (next) button setting the interval for All sports statistics pieChart
    @IBAction func OSnext(_ sender: Any) {
        self.OSinterval.next()
        let text = self.OSinterval.getInterval().0
        OSintervalLabel.text = text
        initPieChartWithFetch()
    }
    
    /// Left (previous) button setting the interval for All sports statistics pieChart
    @IBAction func OSprevious(_ sender: Any) {
        self.OSinterval.previous()
        let text = self.OSinterval.getInterval().0
        OSintervalLabel.text = text
        initPieChartWithFetch()
    }
    
    @objc func notificationSportChanged(_ notificationData: NSNotification) {
        let data = notificationData.userInfo
        let sportSelected = data?["sportSelected"] as? Int ?? 0
        actualSport = sportSelected
        sportSelectButton.image = SportType.sportsArray[sportSelected].image
        
        initBarChartWithFetch()
    }
    
    /// Setting different gestures for next/back buttons that are handling intervals for charts
    func setGestures(){
        
        let gestureRecognizerLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeRecognizerLeft(_:)))
        gestureRecognizerLeft.numberOfTouchesRequired = 1
        gestureRecognizerLeft.direction = .left
        CSSintervalLabel.addGestureRecognizer(gestureRecognizerLeft)
        
        let OSgestureRecognizerLeft = UISwipeGestureRecognizer(target: self, action: #selector(OSswipeRecognizerLeft(_:)))
        OSgestureRecognizerLeft.numberOfTouchesRequired = 1
        OSgestureRecognizerLeft.direction = .left
        OSintervalLabel.addGestureRecognizer(OSgestureRecognizerLeft)
        
        let gestureRecognizerRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeRecognizerRight(_:)))
        gestureRecognizerRight.numberOfTouchesRequired = 1
        gestureRecognizerRight.direction = .right
        CSSintervalLabel.addGestureRecognizer(gestureRecognizerRight)
        
        let OSgestureRecognizerRight = UISwipeGestureRecognizer(target: self, action: #selector(OSswipeRecognizerRight(_:)))
        OSgestureRecognizerRight.numberOfTouchesRequired = 1
        OSgestureRecognizerRight.direction = .right
        OSintervalLabel.addGestureRecognizer(OSgestureRecognizerRight)
    }
    
    @objc func swipeRecognizerLeft(_ gesture: UISwipeGestureRecognizer){
        CSSnext(self)
    }
    @objc func swipeRecognizerRight(_ gesture: UISwipeGestureRecognizer){
        CSSprevious(self)
    }
    @objc func OSswipeRecognizerLeft(_ gesture: UISwipeGestureRecognizer){
        OSnext(self)
    }
    @objc func OSswipeRecognizerRight(_ gesture: UISwipeGestureRecognizer){
        OSprevious(self)
    }
}

// MARK: FETCHED RESULTS CONTROLLER
extension StatsViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .update:
            fallthrough
        case .insert:
            fallthrough
        case .delete:
                
            let records = self.FRCStats.fetchedObjects
            let text = self.barChart.updateBarChart(records: records ?? [],
                                               interval: self.CSSinterval.getInterval().0,
                                               days: self.CSSinterval.getInterval().1)
            self.CSStimeLabel.text = text
            
            let recordsPie = self.FRCPieChart.fetchedObjects
            self.pieChart.updatePieChart(records: recordsPie ?? [])
        default:
            break
        }
    }
}

// MARK: CHARTS VIEWS CONTROLLERS
extension StatsViewController {
   
    /// Fill BarChart with data
    func initBarChartWithFetch() {
        
        if (actualSport != 0){
            FRCStats.fetchRequest.predicate = NSPredicate(format: "sport = %d AND date <= %@ AND date >= %@", actualSport, Date() as NSDate, Date().getXdaysAgoDate(daysAgo: self.CSSinterval.getInterval().1) as NSDate)
        }
        else{
            FRCStats.fetchRequest.predicate = NSPredicate(format: "date <= %@ AND date >= %@", Date() as NSDate, Date().getXdaysAgoDate(daysAgo: self.OSinterval.getInterval().1) as NSDate)
        }
        
        do {
            try FRCStats.performFetch()
        } catch {
            print("Unable to FETCH")
        }
        
        barChart.setXlabels(interval: self.CSSinterval.getInterval().0, labels: barChart.getLabels(interval: self.CSSinterval.getInterval().0))
        
        let records = self.FRCStats.fetchedObjects
        let text = barChart.updateBarChart(records: records ?? [],
                                           interval: self.CSSinterval.getInterval().0,
                                           days: self.CSSinterval.getInterval().1)
        self.CSStimeLabel.text = text
    }
    
    /// Fill PieChart with data
    func initPieChartWithFetch(){
        
        FRCPieChart.fetchRequest.predicate = NSPredicate(format: "date <= %@ AND date >= %@", Date() as NSDate, Date().getXdaysAgoDate(daysAgo: self.OSinterval.getInterval().1) as NSDate)
        
        do {
            try FRCPieChart.performFetch()
        } catch {
            print("Unable to FETCH")
        }
        
        let records = self.FRCPieChart.fetchedObjects
        self.pieChart.updatePieChart(records: records ?? [])
    }

}
