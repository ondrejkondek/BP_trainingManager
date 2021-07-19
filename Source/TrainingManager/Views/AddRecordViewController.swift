//
//  AddRecordViewController.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 15/02/2021.
//

import UIKit
import CoreData

class AddRecordViewController: UIViewController, UIPickerViewDelegate {
    
    let context = getMOC()
    
    public var recordInfo: RecordInfo?
    
    @IBOutlet weak var timePicker: UIPickerView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var sportImage: UIImageView!
    @IBOutlet weak var sportButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboardWhenTapAway()
        
        timePicker.delegate = self
        timePicker.dataSource = self
        
        timePicker.selectRow(recordInfo?.time.hours ?? 0, inComponent: 0, animated: false)
        timePicker.selectRow(recordInfo?.time.minutes ?? 0, inComponent: 2, animated: false)
        timePicker.selectRow(recordInfo?.time.seconds ?? 0, inComponent: 4, animated: false)
        
        sportImage.image = SportType.sportsArray[UserDefaultsManager.shared.getActualSport()].image
        sportButton.setTitle(SportType.sportsArray[UserDefaultsManager.shared.getActualSport()].idName, for: .normal)
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .day, .month], from: recordInfo?.date ?? Date())
        let year = components.year, day = components.day, month = components.month
        let setDate = Date().getDate(year: year ?? 2021, month: month ?? 1, day: day ?? 1)
        datePicker.date = setDate
        
        dateLabel.text = "\(String(day!)). " + "\(String(month!)). " + "\(String(year!))"
        
        locationButton.setTitle(recordInfo?.location, for: .normal)
        notesTextField.text = recordInfo?.notes
    }

    @IBAction func saveRecord(_ sender: Any) {
   
        if (UserDefaultsManager.shared.getActualSport() != 0){
            let newRecord = Record(context: self.context)

            let locationLabel = locationButton.titleLabel?.text ?? ""
            if (locationLabel != "") && (locationLabel != "Location") {
                newRecord.location = locationLabel
            }
            else{
                newRecord.location = ""
            }
            
            newRecord.notes = notesTextField.text
            newRecord.sport = Int16(UserDefaultsManager.shared.getActualSport())
            
            let hours = (recordInfo?.time.hours ?? 0) * 3600
            let minutes = (recordInfo?.time.minutes ?? 0) * 60
            let seconds = recordInfo?.time.seconds ?? 0
            newRecord.time = Int32(hours + minutes + seconds)
            
            let year = datePicker.calendar.component(.year, from: datePicker.date)
            let month = datePicker.calendar.component(.month, from: datePicker.date)
            let day = datePicker.calendar.component(.day, from: datePicker.date)
            newRecord.date = Date().getDate(year: year, month: month, day: day)
            
            if (CoreDataManager.shared.saveData() != 0){
                let alert = UIAlertController(title: "Failed", message: "Unable to save changes! Please try again.", preferredStyle: .alert)
                alert.createOkAlert()
                self.present(alert, animated: true, completion: nil)
            }
            
            self.performSegue(withIdentifier: "unwindBackToRecordView2", sender: self)
            self.dismiss(animated: true, completion: nil)
        }
        else{
            let alert = UIAlertController(title: "Failed", message: "You need to choose a specific sport before saving a record", preferredStyle: .alert)
            alert.createOkCancelAlert()
            self.present(alert, animated: true, completion: nil)
        }
                
    }
    
    @IBAction func discardRecord(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func makeNote(_ sender: Any) {
        let alert = UIAlertController(title: "Notes", message: "You may write your notes about the training here", preferredStyle: .alert)
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "It was raining a lot..."
            if (self.notesTextField.text != ""){
                textField.text = self.notesTextField.text
            }
        }
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { action in
            switch action.style{
            case .default:
                if (alert.textFields![0].text != ""){
                    self.notesTextField.text = alert.textFields![0].text
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
    
    @IBAction func pickDate(_ sender: Any) {
        let year = datePicker.calendar.component(.year, from: datePicker.date)
        let month = datePicker.calendar.component(.month, from: datePicker.date)
        let day = datePicker.calendar.component(.day, from: datePicker.date)
        
        dateLabel.text = "\(day). " + "\(month). " + "\(year)"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "getLocation2" {
            let vc = segue.destination as? LocationViewController
            vc?.fromView = 1
        }
        if segue.identifier == "selectSportForRecord" {
            let vc = segue.destination as? SportSelectTableViewController
            vc?.fromView = 4
        }
    }
    
    @IBAction func unwindBackToAddRecordView(segue: UIStoryboardSegue) {
    }
    
    @IBAction func unwindBackToAddRecordViewFromSelectSport(segue: UIStoryboardSegue) {
    }
    
}

// MARK: Implementation of UIPickerView -> Time Picker
extension AddRecordViewController: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 5
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 25
        case 1, 3:
            return 1
        case 2, 4:
            return 60
        default:
            return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        let ratio = pickerView.frame.size.width/5
        
        if (component == 1) || (component == 3){
            return ratio * 0.3
        }
        else {
            return ratio
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "Avenir Next", size: 50)
            pickerLabel?.textAlignment = .center
        }
        
        pickerLabel?.textColor = .black
        pickerLabel?.text = String(format: "%02d", row)
        
        if (component == 1) || (component == 3){
            pickerLabel?.text = ":"
        }
        
        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            recordInfo?.time.hours = row
        case 2:
            recordInfo?.time.minutes = row
        case 4:
            recordInfo?.time.seconds = row
        default:
            break;
        }
    }
}
