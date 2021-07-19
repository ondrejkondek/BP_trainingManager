//
//  DetailsRecordViewController.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 06/03/2021.
//

import UIKit

class DetailsRecordViewController: UIViewController {

    let context = getMOC()
    public var record: Record!
    var time = Time()
    var fromView = 0
    
    @IBOutlet weak var timePicker: UIPickerView!
    @IBOutlet weak var sportImage: UIImageView!
    @IBOutlet weak var sportLabel: UILabel!
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboardWhenTapAway()
        
        timePicker.delegate = self
        timePicker.dataSource = self
        
        time = time.secToHoursMinSec(seconds: Int(record.time))
        timePicker.selectRow(time.hours ?? 0, inComponent: 0, animated: false)
        timePicker.selectRow(time.minutes ?? 0, inComponent: 2, animated: false)
        timePicker.selectRow(time.seconds ?? 0, inComponent: 4, animated: false)
        
        sportImage.image = SportType.sportsArray[Int(record.sport)].image
        sportLabel.text = SportType.sportsArray[Int(record.sport)].idName
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .day, .month], from: record.date ?? Date())
        let year = components.year, day = components.day, month = components.month
        let setDate = Date().getDate(year: year ?? 2021, month: month ?? 1, day: day ?? 1)
        datePicker.date = setDate
        
        dateLabel.text = "\(String(day!)). " + "\(String(month!)). " + "\(String(year!))"
        locationButton.setTitle(record.location, for: .normal)
        notesTextField.text = record.notes
    }
    
    @IBAction func pickDate(_ sender: Any) {
        let year = datePicker.calendar.component(.year, from: datePicker.date)
        let month = datePicker.calendar.component(.month, from: datePicker.date)
        let day = datePicker.calendar.component(.day, from: datePicker.date)
        
        dateLabel.text = "\(day). " + "\(month). " + "\(year)"
    }
    
    @IBAction func editNote(_ sender: Any) {
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
    
    @IBAction func saveRecord(_ sender: Any) {
        
        let locationLabel = locationButton.titleLabel?.text ?? ""
        if (locationLabel != "") && (locationLabel != "Location") {
            record.location = locationLabel
        }
        else{
            record.location = ""
        }
        record.notes = notesTextField.text
        
        let hours = (time.hours ?? 0) * 3600
        let minutes = (time.minutes ?? 0) * 60
        let seconds = time.seconds ?? 0
        record.time = Int32(hours + minutes + seconds)
        
        let year = datePicker.calendar.component(.year, from: datePicker.date)
        let month = datePicker.calendar.component(.month, from: datePicker.date)
        let day = datePicker.calendar.component(.day, from: datePicker.date)
        record.date = Date().getDate(year: year, month: month, day: day)
        
        if (CoreDataManager.shared.saveData() != 0){
            let alert = UIAlertController(title: "Failed", message: "Unable to save changes! Please try again.", preferredStyle: .alert)
            alert.createOkAlert()
            self.present(alert, animated: true, completion: nil)
        }
        
        if (fromView == 0){
            performSegue(withIdentifier: "unwindBackToCalendarViewFromDetailsRecordView", sender: self)
        }
        else{
            performSegue(withIdentifier: "unwindBackToBarChartViewFromDetailsRecordView", sender: self)
        }
        
    }
    
    @IBAction func deleteRecord(_ sender: Any) {
        
        let alert = UIAlertController(title: "Are you sure to delete this record?", message: "You cannot undo this action.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                self.context.delete(self.record)
                
                if (CoreDataManager.shared.saveData() != 0){
                    let alert = UIAlertController(title: "Failed", message: "Unable to save changes! Please try again.", preferredStyle: .alert)
                    alert.createOkAlert()
                    self.present(alert, animated: true, completion: nil)
                }
                
                if (self.fromView == 0){
                    self.performSegue(withIdentifier: "unwindBackToCalendarViewFromDetailsRecordView", sender: self)
                }
                else{
                    self.performSegue(withIdentifier: "unwindBackToBarChartViewFromDetailsRecordView", sender: self)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "getLocation3" {
            let vc = segue.destination as? LocationViewController
            vc?.fromView = 2
        }
    }
    
    /// Unwind back from Location VC
    @IBAction func unwindBackToDetailsRecordView(segue: UIStoryboardSegue) {
    }

}

// MARK: Implementation of UIPickerView -> Time Picker
extension DetailsRecordViewController: UIPickerViewDataSource, UIPickerViewDelegate {

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
            time.hours = row
        case 2:
            time.minutes = row
        case 4:
            time.seconds = row
        default:
            break;
        }
    }
}
