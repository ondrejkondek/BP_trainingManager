//
//  SiriTableViewController.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 12/03/2021.
//

import UIKit
import Intents
import IntentsUI

class SiriTableViewController: UITableViewController {

    let sectionsSpec = [3]     // static size of tableView
    var voiceShortcutStartTrainingID: UUID?
    var voiceShortcutStopTrainingID: UUID?
    var voiceShortcutShowStatsID: UUID?
    var chosenCell: String?
    
    @IBOutlet weak var startTrainingCell: UITableViewCell!
    @IBOutlet weak var stopTrainingCell: UITableViewCell!
    @IBOutlet weak var showStatisticsCell: UITableViewCell!
    @IBOutlet weak var navItem: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init checkmarks
        if let startTrainingID = UserDefaultsManager.shared.getSiriVoiceShortcut(key: "startTraining"){
            startTrainingCell.accessoryType = .checkmark
            voiceShortcutStartTrainingID = startTrainingID
        }
        else{
            startTrainingCell.accessoryType = .none
        }
        
        if let stopTrainingID = UserDefaultsManager.shared.getSiriVoiceShortcut(key: "stopTraining"){
            stopTrainingCell.accessoryType = .checkmark
            voiceShortcutStopTrainingID = stopTrainingID
        }
        else{
            stopTrainingCell.accessoryType = .none
        }
     
        if let showStatsID = UserDefaultsManager.shared.getSiriVoiceShortcut(key: "showStats"){
            showStatisticsCell.accessoryType = .checkmark
            voiceShortcutShowStatsID = showStatsID
        }
        else{
            showStatisticsCell.accessoryType = .none
        }
    }

    /// Creating UserActivity for the system
    /// UserActivity is eligible for search and prediction
    /// - Parameter activityType: ID of the shortcut
    /// - Parameter title: Title to be shown
    /// - Parameter suggestedPhrase: phrase for Siri
    /// - Returns: NSUserActivity
    func createUserActivity(activityType: String, title: String, suggestedPhrase: String) -> NSUserActivity{
        
        let activity = NSUserActivity(activityType: activityType)
        
        activity.title = title
        activity.suggestedInvocationPhrase = suggestedPhrase
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        
        return activity
    }
    
    /// Siri shortcut handler - presenting Siri VCs
    /// - Parameter cell: ID of the clicked cell
    /// - Parameter voiceShortcutID: UUID of the voiceshortcut
    /// - Parameter activity: NSUserActivity
    func handleSiriShortcut(cell: String, voiceShortcutID: UUID?, activity: NSUserActivity){
        
        if let id = voiceShortcutID {
            INVoiceShortcutCenter.shared.getVoiceShortcut(with: id) {
                shortcut, error in
                // voiceshortcut already exists
                if let shortcut = shortcut, error == nil{
                    DispatchQueue.main.async {
                        self.chosenCell = cell
                        let vc = INUIEditVoiceShortcutViewController(voiceShortcut: shortcut)
                        vc.delegate = self
                        self.present(vc, animated: true, completion: nil)
                    }
                }
                // if error occurs
                else{
                    DispatchQueue.main.async {
                        self.chosenCell = cell
                        let shortcut = INShortcut(userActivity: activity)
                        let vc = INUIAddVoiceShortcutViewController(shortcut: shortcut)
                        vc.delegate = self
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }
        }
        // create a new voiceshorcut
        else{
            self.chosenCell = cell
            let shortcut = INShortcut(userActivity: activity)
            let vc = INUIAddVoiceShortcutViewController(shortcut: shortcut)
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }

    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsSpec.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionsSpec[section]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.indexPath(for: startTrainingCell), cell == indexPath {
            let activity = self.createUserActivity(activityType: "ondrejkondek.TrainingManager.StartTraining", title: "Start a new training", suggestedPhrase: "Start training!")
            handleSiriShortcut(cell: "startTraining", voiceShortcutID: self.voiceShortcutStartTrainingID, activity: activity)
        }
        
        if let cell = tableView.indexPath(for: stopTrainingCell), cell == indexPath {
            let activity = self.createUserActivity(activityType: "ondrejkondek.TrainingManager.StopTraining", title: "Stop the training", suggestedPhrase: "Stop training!")
            handleSiriShortcut(cell: "stopTraining", voiceShortcutID: self.voiceShortcutStopTrainingID, activity: activity)
        }
        
        if let cell = tableView.indexPath(for: showStatisticsCell), cell == indexPath {
            let activity = self.createUserActivity(activityType: "ondrejkondek.TrainingManager.ShowStats", title: "Show my statistics", suggestedPhrase: "Show stats!")
            handleSiriShortcut(cell: "showStats", voiceShortcutID: self.voiceShortcutShowStatsID, activity: activity)
        }
    }
}

// MARK: INUIAddVoiceShortcutViewController Delegate methods
extension SiriTableViewController: INUIAddVoiceShortcutViewControllerDelegate {
   
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        
        if self.chosenCell == "startTraining" {
            
            voiceShortcutStartTrainingID = voiceShortcut?.identifier
            if let uuid = voiceShortcut?.identifier {
                UserDefaultsManager.shared.setSiriVoiceShortcut(key: "startTraining", uuid: uuid)
                startTrainingCell.accessoryType = .checkmark
            }
        }
        else if self.chosenCell == "stopTraining" {
            
            voiceShortcutStopTrainingID = voiceShortcut?.identifier
            if let uuid = voiceShortcut?.identifier {
                UserDefaultsManager.shared.setSiriVoiceShortcut(key: "stopTraining", uuid: uuid)
                stopTrainingCell.accessoryType = .checkmark
            }
        }
        else if self.chosenCell == "showStats" {
            
            voiceShortcutShowStatsID = voiceShortcut?.identifier
            if let uuid = voiceShortcut?.identifier {
                UserDefaultsManager.shared.setSiriVoiceShortcut(key: "showStats", uuid: uuid)
                showStatisticsCell.accessoryType = .checkmark
            }
        }
 
        self.chosenCell = nil
        dismiss(animated: true, completion: nil)
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        self.chosenCell = nil
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: INUIEditVoiceShortcutViewController Delegate methods
extension SiriTableViewController: INUIEditVoiceShortcutViewControllerDelegate {
    
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didUpdate voiceShortcut: INVoiceShortcut?, error: Error?) {
        self.chosenCell = nil
        controller.dismiss(animated: true)
    }

    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
        
        if self.chosenCell == "startTraining" {
            UserDefaultsManager.shared.removeSiriVoiceShortcut(key: "startTraining", uuid: deletedVoiceShortcutIdentifier)
            startTrainingCell.accessoryType = .none
            voiceShortcutStartTrainingID = nil
        }
        else if self.chosenCell == "stopTraining" {
            UserDefaultsManager.shared.removeSiriVoiceShortcut(key: "stopTraining", uuid: deletedVoiceShortcutIdentifier)
            stopTrainingCell.accessoryType = .none
            voiceShortcutStopTrainingID = nil
        }
        else if self.chosenCell == "showStats" {
            UserDefaultsManager.shared.removeSiriVoiceShortcut(key: "showStats", uuid: deletedVoiceShortcutIdentifier)
            showStatisticsCell.accessoryType = .none
            voiceShortcutShowStatsID = nil
        }
        
        self.chosenCell = nil
        controller.dismiss(animated: true)
    }

    func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
        self.chosenCell = nil
        controller.dismiss(animated: true)
    }
}
