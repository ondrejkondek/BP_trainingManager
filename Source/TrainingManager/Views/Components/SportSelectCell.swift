//
//  SportSelectCell.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 18/02/2021.
//

import UIKit

class SportSelectCell: UITableViewCell {

    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imageSport: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
