//
//  CalendarCell.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 28/02/2021.
//

import UIKit

class CalendarCell: UITableViewCell {

    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var sportImage: UIImageView!
    @IBOutlet weak var middleLabel: UILabel!
    
    var calendarCellModel: Record! {
        didSet{
            
            if (calendarCellModel.notes == "") && (calendarCellModel.location == ""){
                notesLabel.text = calendarCellModel.notes
                locationLabel.text = calendarCellModel.location
                middleLabel.isHidden = true
            }
            else if (calendarCellModel.notes == ""){
                middleLabel.text = calendarCellModel.location
                middleLabel.isHidden = false
                notesLabel.isHidden = true
                locationLabel.isHidden = true
            }
            else if (calendarCellModel.location == "") {
                middleLabel.text = calendarCellModel.notes
                middleLabel.isHidden = false
                notesLabel.isHidden = true
                locationLabel.isHidden = true
            }
            
            notesLabel.text = calendarCellModel.notes
            locationLabel.text = calendarCellModel.location
            
            timeLabel.text = Time().getTimeFromSeconds(Int(calendarCellModel.time), minretval: "seconds")
            sportImage.image = SportType.sportsArray[Int(calendarCellModel.sport)].image
        }
    }    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
