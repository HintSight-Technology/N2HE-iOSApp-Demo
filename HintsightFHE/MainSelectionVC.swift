//
//  MainSelectionVCViewController.swift
//  HintsightFHE
//
//  Created by Luo Kaiwen on 29/7/24.
//

import UIKit
import AVFoundation


class MainSelectionVC: UIViewController {

    let svButton = HSHeaderButton(color: .systemCyan, title: "Speaker Verification")
    let fvButton = HSHeaderButton(color: .systemGreen, title: "Facial Verification")
    let hsImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubviews(fvButton, svButton, hsImageView)
        configureFVButton()
        configureSVButton()
        configureHSImageView()
    }
    
    @objc func pushFacialVerificationVC() {
        let speakerVerificationVC = FacialVerificationVC()
        navigationController?.pushViewController(speakerVerificationVC, animated: true)
    }
    
    @objc func pushSpeakerVerificationVC() {
        let speakerVerificationVC = SpeakerVerificationVC()
        navigationController?.pushViewController(speakerVerificationVC, animated: true)
    }
    
    func configureFVButton() {
        fvButton.addTarget(self, action: #selector(pushFacialVerificationVC), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            fvButton.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 30),
            fvButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            fvButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            fvButton.heightAnchor.constraint(equalToConstant: 50)
        ])    }
    
    func configureSVButton() {
        svButton.addTarget(self, action: #selector(pushSpeakerVerificationVC), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            svButton.topAnchor.constraint(equalTo: fvButton.bottomAnchor, constant: 50),
            svButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            svButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            svButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func configureHSImageView() {
        hsImageView.translatesAutoresizingMaskIntoConstraints = false
        hsImageView.image = UIImage(resource: .hsLogo)
        
        NSLayoutConstraint.activate([
            hsImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            hsImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hsImageView.heightAnchor.constraint(equalToConstant: 250),
            hsImageView.widthAnchor.constraint(equalToConstant: 375)
        ])
    }
    
}
