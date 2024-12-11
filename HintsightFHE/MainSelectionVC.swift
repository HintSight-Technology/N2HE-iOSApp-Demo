//
//  MainSelectionVCViewController.swift
//  HintsightFHE
//
//  Created by Luo Kaiwen on 29/7/24.
//

import UIKit
import AVFoundation


class MainSelectionVC: UIViewController {
    
    private let svButton = HSHeaderButton(buttonColor: UIColor(hexString: Colors.green.rawValue, alpha: 1) ?? .systemGreen, titleColor: .black, title: "Speaker Verification")
    private let fvButton = HSHeaderButton(buttonColor: UIColor(hexString: Colors.blue.rawValue, alpha: 1) ?? .systemCyan, titleColor: .black, title: "Facial Verification")
    private let hsImageView = UIImageView()
    private let screenSizes = ScreenSizes()
    private var screenHeight = 0.0
    private var screenWidth = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenSizes.setScreenHeight(height: UIScreen.main.bounds.height)
        screenSizes.setScreenWidth(width: UIScreen.main.bounds.width)
        screenHeight = UIScreen.main.bounds.height
        screenWidth = UIScreen.main.bounds.width

        view.backgroundColor = UIColor(hexString: Colors.background.rawValue, alpha: 1) ?? .white
        view.addSubviews(fvButton, svButton, hsImageView)
        configureFVButton()
        configureSVButton()
        configureHSImageView()
    }
    
    @objc func pushFacialVerificationVC() {
        let facialVerificationVC = FacialVerificationVC(screenWidth: self.screenWidth, screenHeight: self.screenHeight)
        navigationController?.pushViewController(facialVerificationVC, animated: true)
    }
    
    @objc func pushSpeakerVerificationVC() {
        let speakerVerificationVC = SpeakerVerificationVC(screenWidth: self.screenWidth, screenHeight: self.screenHeight)
        navigationController?.pushViewController(speakerVerificationVC, animated: true)
    }
    
    func configureFVButton() {
        fvButton.addTarget(self, action: #selector(pushFacialVerificationVC), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            fvButton.topAnchor.constraint(equalTo: view.centerYAnchor, constant: (self.screenHeight / 31)), //30
            fvButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: self.screenWidth / 8.6), //50
            fvButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -self.screenWidth / 8.6), //-50
            fvButton.heightAnchor.constraint(equalToConstant: self.screenHeight / 18.64) //50
        ])    }
    
    func configureSVButton() {
        svButton.addTarget(self, action: #selector(pushSpeakerVerificationVC), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            svButton.topAnchor.constraint(equalTo: fvButton.bottomAnchor, constant: self.screenHeight / 18.64), //50
            svButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: self.screenWidth / 8.6), //50
            svButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -self.screenWidth / 8.6), //-50
            svButton.heightAnchor.constraint(equalToConstant: self.screenHeight / 18.64) //50
        ])
    }
    
    func configureHSImageView() {
        hsImageView.translatesAutoresizingMaskIntoConstraints = false
        hsImageView.image = UIImage(resource: .hsLogo)
        
        NSLayoutConstraint.activate([
            hsImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: self.screenHeight / 15.5), //60
            hsImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hsImageView.heightAnchor.constraint(equalToConstant: self.screenHeight / 3.7), //250
            hsImageView.widthAnchor.constraint(equalToConstant: self.screenWidth / 1.15) //375
        ])
    }
    
}


