//
//  UIAlertExtension.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 10/05/2021.
//

import UIKit

// MARK: Creating UIAlertControllers to keep code clean
extension UIAlertController {
    
    func createOkCancelAlert(){
        self.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }
    
    func createOkAlert(){
        self.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    }
    
}
