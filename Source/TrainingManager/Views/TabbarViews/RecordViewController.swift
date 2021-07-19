//
//  RecordViewController.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 12/02/2021.
//

import UIKit
import CoreData
import Intents
import WidgetKit

class RecordViewController: UIViewController, UIPickerViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var notesTextView: UITextField!
    @IBOutlet weak var saveTrainingButton: UIButton!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sportSelectButton: UIBarButtonItem!
    @IBOutlet weak var navItem: UINavigationItem!
    
    var timer: Timer = Timer()
    var counter: Int = 0
    var timerBool: Bool = false     // true if timer is running
    
    var timerCacheDate: Date?       // if app goes to background - time is saved
    var actualSport = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboardWhenTapAway()
        navigationController?.navigationBar.barStyle = .black
        
        startButton.setBackgroundImage(UIImage(named: "play"), for: .normal)
        
        actualSport = UserDefaultsManager.shared.getActualSport()
        sportSelectButton.image = SportType.sportsArray[actualSport].image
        
        let year = datePicker.calendar.component(.year, from: datePicker.date)
        let month = datePicker.calendar.component(.month, from: datePicker.date)
        let day = datePicker.calendar.component(.day, from: datePicker.date)
        
        dateLabel.text = "\(day). " + "\(month). " + "\(year)"
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationSportChanged(_ :)), name: Notification.Name("sportChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sceneBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sceneWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
}

    override func viewWillAppear(_ animated: Bool) {
        // if app was in background and not loaded before
        controlUserActivities()
    }
    
    @objc func sceneBecomeActive(){
        // if app was in background
        if let cacheDate = self.timerCacheDate, timerBool == true {
           
            let seconds = cacheDate.secondsDifference(to: Date())
            
            counter += seconds
            // update label
            let time = Time().secToHoursMinSec(seconds: counter)
            let labelText = Time().timeToString(hours: time.hours, minutes: time.minutes, seconds: time.seconds)
            timerLabel.text = labelText
        }
        
        controlUserActivities()
    }
    
    @objc func sceneWillResignActive(){
        
        // keep timer running when app is in background
        if timerBool {
            self.timerCacheDate = Date()
        }
    }
    
    /// Handle all possible actions from Siri, Widget, Context menu
    func controlUserActivities() {
        
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            
            if (sceneDelegate.play){
                if (timerBool == false){
                    startTimer(self)
                }
                sceneDelegate.play = false
            }
            
            if (sceneDelegate.pause){
                if timerBool{
                    startTimer(self)
                }
                sceneDelegate.pause = false
            }
            
            if (sceneDelegate.reset) {
                resetTimer(self)
                sceneDelegate.reset = false
            }
            
            if (sceneDelegate.widgetPlay){
                startTimer(self)
                sceneDelegate.widgetPlay = false
            }
        }
    }
    
    @objc func notificationSportChanged(_ notificationData: NSNotification) {
        let data = notificationData.userInfo
        let sportSelected = data?["sportSelected"] as? Int ?? 0
        actualSport = sportSelected
        sportSelectButton.image = SportType.sportsArray[sportSelected].image
    }
    
    @IBAction func createTraining(_ sender: Any) {
        
        if (actualSport != 0){
            performSegue(withIdentifier: "oldNewTraining", sender: self)
        }
        else{
            pushAlertWithWarning()
        }
    }
    
    @IBAction func saveTraining(_ sender: Any) {
        
        if (actualSport != 0){
            if ((counter != 0) && (timerBool == false)){
                performSegue(withIdentifier: "newTraining", sender: self)
            }
        }
        else{
            pushAlertWithWarning()
        }
    }
    
    @IBAction func makeNote(_ sender: Any) {
        
        let alert = UIAlertController(title: "Notes", message: "You may write your notes about the training here", preferredStyle: .alert)
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "It was raining a lot..."
            if (self.notesTextView.text != ""){
                textField.text = self.notesTextView.text
            }
        }
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { action in
            switch action.style{
            case .default:
                if (alert.textFields![0].text != ""){
                    self.notesTextView.text = alert.textFields![0].text
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
    
    @IBAction func startTimer(_ sender: Any) {
        
        if (timerBool){
            
            timerBool = false
            timer.invalidate()
            startButton.setBackgroundImage(UIImage(named: "play"), for: .normal)
            // passing info to widget
            UserDefaultsManager.shared.widgetTrainingInfo(sport: actualSport, running: false, reset: false, setTime: false)
            
            saveTrainingButton.alpha = 1
        }
        else{
            if counter == 0 {
                // passing info to widget
                UserDefaultsManager.shared.widgetTrainingInfo(sport: actualSport, running: true, reset: false, setTime: true)
            }
            else{
                // passing info to widget
                UserDefaultsManager.shared.widgetTrainingInfo(sport: actualSport, running: true, reset: false, setTime: false)
            }
            self.timerBool = true
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerCounter), userInfo: nil, repeats: true)
            self.startButton.setBackgroundImage(UIImage(named: "pause"), for: .normal)
            
            saveTrainingButton.alpha = 0.6
        }
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    @objc func timerCounter() {
        counter += 1
        let time = Time().secToHoursMinSec(seconds: counter)
        let labelText = Time().timeToString(hours: time.hours, minutes: time.minutes, seconds: time.seconds)
        timerLabel.text = labelText
    }
    
    @IBAction func resetTimer(_ sender: Any) {
        counter = 0
        timer.invalidate()
        timerBool = false
        timerLabel.text = Time().timeToString(hours: 0, minutes: 0, seconds: 0)
        startButton.setBackgroundImage(UIImage(named: "play"), for: .normal)
        
        // passing info to widget
        UserDefaultsManager.shared.widgetTrainingInfo(sport: actualSport, running: false, reset: true, setTime: false)
        WidgetCenter.shared.reloadAllTimelines()
        
        saveTrainingButton.alpha = 0.6
    }
        
    @IBAction func pickDate(_ sender: Any) {
        let year = datePicker.calendar.component(.year, from: datePicker.date)
        let month = datePicker.calendar.component(.month, from: datePicker.date)
        let day = datePicker.calendar.component(.day, from: datePicker.date)
        
        dateLabel.text = "\(day). " + "\(month). " + "\(year)"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "newTraining" {
            let newTraining = segue.destination as? AddRecordViewController

            var recordInfo = RecordInfo()

            let year = datePicker.calendar.component(.year, from: datePicker.date)
            let month = datePicker.calendar.component(.month, from: datePicker.date)
            let day = datePicker.calendar.component(.day, from: datePicker.date)

            recordInfo.date = Date().getDate(year: year, month: month, day: day)
            recordInfo.time = Time().secToHoursMinSec(seconds: self.counter)
            recordInfo.location = locationButton.titleLabel?.text ?? ""
            recordInfo.notes = notesTextView.text ?? ""

            newTraining?.recordInfo = recordInfo
        }
        else if segue.identifier == "oldNewTraining" {
            let newTraining = segue.destination as? AddRecordViewController
            
            var recordInfo = RecordInfo()
            
            recordInfo.date = Date()
            recordInfo.time = Time().secToHoursMinSec(seconds: 0)
            recordInfo.location = "Location"
            recordInfo.notes = ""
            
            newTraining?.recordInfo = recordInfo
        }
        else if segue.identifier == "chooseSportFromRecord" {
            let vc = segue.destination as? SportSelectTableViewController
            vc?.fromView = 2
        }
        else if segue.identifier == "getLocation" {
            let vc = segue.destination as? LocationViewController
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            backItem.tintColor = UIColor.white
            self.navItem.backBarButtonItem = backItem
            vc?.fromView = 0
        }
    }
    
    /// unwind back from AddRecord VC
    @IBAction func unwindBackToRecordView(segue: UIStoryboardSegue) {
    }
    
    /// unwind back from Location VC
    @IBAction func unwindBackToRecordView2(segue: UIStoryboardSegue) {
        resetTimer(self)
        notesTextView.text = ""
        locationButton.setTitle("Location", for: .normal)
    }
}

// MARK: UIAlertController with warning used in the RecordViewController
extension RecordViewController {
    
    func pushAlertWithWarning() {
        let alert = UIAlertController(title: "Failed", message: "You need to choose a specific sport before saving a record", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                break
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
}
