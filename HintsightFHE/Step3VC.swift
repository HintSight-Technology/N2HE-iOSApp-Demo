//
//  Step3VC.swift
//  HintsightFHE
//
//  Created by Luo Kaiwen on 3/12/24.
//

import UIKit

class Step3VC: UIViewController {

    private let stepTitle = UILabel()
    private let downRightArrow = UIImageView()
    private let downBackwardArrow = UIImageView()
    private let stepDescription = UITextView()
    private let encryptedFeaturesImageView = UIImageView()
    private let cloudServerImageView = UIImageView()
    private let encryptedResultImageView = UIImageView()
    private let encryptedDataImageView = UIImageView()
    
    private var screenHeight = 0.0
    private var screenWidth = 0.0
    
    init(screenHeight: CGFloat = 0.0, screenWidth: CGFloat = 0.0) {
        super.init(nibName: nil, bundle: nil)
        self.screenHeight = screenHeight
        self.screenWidth = screenWidth
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexString: Colors.background.rawValue, alpha: 1) ?? .white
        view.addSubviews(stepTitle, downRightArrow, downBackwardArrow, stepDescription, encryptedFeaturesImageView,
                         cloudServerImageView, encryptedResultImageView, encryptedDataImageView)
        
        configureStepTitle()
        configureStepDescription()
        configureDownRightArrow()
        configureDownBackwardArrow()
        configureImageViews()
    }
    
    private func configureStepTitle() {
        stepTitle.textColor = UIColor(hexString: Colors.blue.rawValue, alpha: 1) ?? .black
        stepTitle.text = "Step 3: Server Verification"
        stepTitle.font = UIFont.boldSystemFont(ofSize: 20)
        
        stepTitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stepTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stepTitle.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
                
    private func configureStepDescription() {
        stepDescription.backgroundColor = UIColor(hexString: Colors.background.rawValue, alpha: 1) ?? .white
        let description = "The encrypted features are sent to the cloud server through POST request for verification. During this process, data is always encrypted. GET request is used to send the encrypted result back to this device."
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        paragraphStyle.alignment = NSTextAlignment.center
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .medium),
            NSAttributedString.Key.foregroundColor: UIColor.systemGray2,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]
        let attributedString = NSAttributedString(string: description, attributes: attributes)
        stepDescription.attributedText = attributedString
        
        stepDescription.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stepDescription.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stepDescription.topAnchor.constraint(equalTo: stepTitle.bottomAnchor, constant: 24),
            stepDescription.widthAnchor.constraint(equalToConstant: self.screenWidth/1.43),
            stepDescription.heightAnchor.constraint(equalToConstant: self.screenHeight/3.73)
        ])
    }
    
    private func configureImageViews() {
        let imageViewConfig = UIImage.SymbolConfiguration(pointSize: 60)
        encryptedFeaturesImageView.image = UIImage(systemName: "lock.doc", withConfiguration: imageViewConfig)
        encryptedFeaturesImageView.tintColor = .black
        encryptedFeaturesImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            encryptedFeaturesImageView.centerXAnchor.constraint(equalTo: view.leadingAnchor,
                                                                constant: self.screenWidth/4.3),
            encryptedFeaturesImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                                constant: self.screenHeight/9.32)
        ])
        
        encryptedResultImageView.image = UIImage(systemName: "lock.doc", withConfiguration: imageViewConfig)
        encryptedResultImageView.tintColor = .black
        encryptedResultImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            encryptedResultImageView.centerXAnchor.constraint(equalTo: view.leadingAnchor, constant: self.screenWidth/4.3),
            encryptedResultImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                              constant: self.screenHeight/3.33) //280
        ])
        
        let icloudConfig = UIImage.SymbolConfiguration(pointSize: 80)
        cloudServerImageView.image = UIImage(systemName: "icloud", withConfiguration: icloudConfig)
        cloudServerImageView.tintColor = .black
        cloudServerImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cloudServerImageView.centerXAnchor.constraint(equalTo: view.trailingAnchor, constant: -self.screenWidth/4.3),
            cloudServerImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                          constant: self.screenHeight/4.44) //210
        ])
        
        let smallLockDocConfig = UIImage.SymbolConfiguration(pointSize: 30)
        encryptedDataImageView.image = UIImage(systemName: "lock.doc", withConfiguration: smallLockDocConfig)
        encryptedDataImageView.tintColor = .black
        encryptedDataImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            encryptedDataImageView.centerXAnchor.constraint(equalTo: view.trailingAnchor, constant: -self.screenWidth/4.3),
            encryptedDataImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                            constant: self.screenHeight/4.44) //210
        ])
    }
    
    private func configureDownRightArrow() {
        let downRightArrowConfig = UIImage.SymbolConfiguration(pointSize: 50)
        downRightArrow.image = UIImage(systemName: "arrow.down.right", withConfiguration: downRightArrowConfig)
        downRightArrow.tintColor = .black
        
        downRightArrow.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            downRightArrow.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            downRightArrow.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                    constant: self.screenHeight/6.21) //150
        ])
    }
    
    private func configureDownBackwardArrow() {
        let downBackwardConfig = UIImage.SymbolConfiguration(pointSize: 50)
        downBackwardArrow.image = UIImage(systemName: "arrow.down.backward", withConfiguration: downBackwardConfig)
        downBackwardArrow.tintColor = .black
        
        downBackwardArrow.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            downBackwardArrow.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            downBackwardArrow.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                       constant: self.screenHeight/3.73)
        ])
    }
    
}
