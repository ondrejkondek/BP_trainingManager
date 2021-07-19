//
//  SportSelectTableViewController.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 18/02/2021.
//

import UIKit
import WidgetKit

class SportSelectTableViewController: UITableViewController {
    
    public var fromView: Int = 2
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return SportType.sportsArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "sport", for: indexPath) as? SportSelectCell else {
            fatalError() }
        
        cell.labelName.text = SportType.sportsArray[indexPath.row].idName
        cell.imageSport.image = SportType.sportsArray[indexPath.row].image
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // unwind back to VC based on from which view this VC was presented
        switch fromView {
        case 0:
            self.performSegue(withIdentifier: "unwindBackToStatsView", sender: self)
        case 1:
            self.performSegue(withIdentifier: "unwindBackToCalendarView", sender: self)
        case 2:
            self.performSegue(withIdentifier: "unwindBackToRecordView", sender: self)
        case 3:
            self.performSegue(withIdentifier: "unwindBackToSocialView", sender: self)
        case 4:
            self.performSegue(withIdentifier: "unwindBackToAddRecordViewFromSelectSport", sender: self)
        default:
            break
        }
        
        let sportSelected = Int(SportType.sportsArray[indexPath.row].idNumber)
        NotificationCenter.default.post(name: Notification.Name("sportChanged"), object: nil, userInfo: ["sportSelected": sportSelected])
        
        let idSport = SportType.sportsArray[indexPath.row].idNumber
        
        UserDefaultsManager.shared.setActualSport(idSport ?? 0)
        // passing info to widget
        UserDefaultsManager.shared.udShared.setValue(idSport ?? 0, forKey: "actualSport")
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let row = tableView.indexPathForSelectedRow?.row
        
        if segue.identifier == "unwindBackToStatsView" {
            let selectedSport = segue.destination as? StatsViewController
            selectedSport?.actualSport = row!
        }
        if segue.identifier == "unwindBackToCalendarView" {
            let selectedSport = segue.destination as? CalendarViewController
            selectedSport?.actualSport = row!
        }
        if segue.identifier == "unwindBackToAddRecordViewFromSelectSport" {
            let vc = segue.destination as? AddRecordViewController
            vc?.sportButton.setTitle(SportType.sportsArray[row!].idName, for: .normal)
            vc?.sportImage.image = SportType.sportsArray[row!].image
        }
        

    }

}
