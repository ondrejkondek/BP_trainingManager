//
//  UIViewControllerExtension.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 02/04/2021.
//

import UIKit

/// This code is highly inspired by the post on stackoverflow.com
/// Authors' nicknames: spacecash21 & Esqarrouth
/// Date: answered Nov 22 '14 at 15:33, edited Nov 19 '20 at 14:52
/// Source: https://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift

extension UIViewController {
    
    /// Software keyboard disappears when user taps out of any text field
    func dismissKeyboardWhenTapAway() {
    
        let gesture = UITapGestureRecognizer(target: self, action: #selector(UIViewController.tapAwayFromKeyboard))
        gesture.cancelsTouchesInView = false
        view.addGestureRecognizer(gesture)
    }
    
    @objc func tapAwayFromKeyboard() {
        view.endEditing(true)
    }
}
