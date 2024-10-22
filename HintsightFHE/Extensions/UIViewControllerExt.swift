//
//  UIViewControllerExt.swift
//  HintsightFHE
//
//  Created by Luo Kaiwen on 7/8/24.
//

import UIKit


extension UIViewController {
    
    func presentHSAlert(title: String, message: String, buttonLabel: String, titleLabelColor: UIColor) {
        let alertVC = HSAlertVC(title: title, message: message, buttonLabel: buttonLabel, titleLabelColor: titleLabelColor)
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        present(alertVC, animated: true)
    }
    
}
