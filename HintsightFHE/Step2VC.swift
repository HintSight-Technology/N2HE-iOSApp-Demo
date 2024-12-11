//
//  Step2VC.swift
//  HintsightFHE
//
//  Created by Luo Kaiwen on 3/12/24.
//

import UIKit

class Step2VC: UIViewController {

    private let stepTitle = UILabel()
    private let rightArrow = UIImageView()
    private let featuresTableView = UITableView()
    private let encryptedFeature1TableView = UITableView()
    private let encryptedFeature2TableView = UITableView()
    private let stepDescription = UITextView()
    
    private var screenHeight = 0.0
    private var screenWidth = 0.0
    private var features: [String] = []
    private var encryptedFeature1: [String] = []
    private var encryptedFeature2: [String] = []
    
    init(features: String = "", encryptedFeatures: String = "", screenHeight: CGFloat = 0.0, screenWidth: CGFloat = 0.0) {
        super.init(nibName: nil, bundle: nil)
        self.features = features.split(separator: ",").map{ String($0) }
        self.encryptedFeature1 = encryptedFeatures.split(separator: ",")[0..<1024].map{ String($0) }
        self.encryptedFeature2 = encryptedFeatures.split(separator: ",")[1024...].map{ String($0) }
        self.screenHeight = screenHeight
        self.screenWidth = screenWidth
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexString: Colors.background.rawValue, alpha: 1) ?? .white
        view.addSubviews(stepTitle, rightArrow, featuresTableView, stepDescription,
                         encryptedFeature1TableView, encryptedFeature2TableView)
        
        configureStepTitle()
        configureArrow()
        configureFeatureTableView()
        configureStepDescription()
        configureEncryptedFeature1TableView()
        configureEncryptedFeature2TableView()
    }
    
    private func configureStepTitle() {
        stepTitle.textColor = UIColor(hexString: Colors.blue.rawValue, alpha: 1) ?? .black
        stepTitle.text = "Step 2: Feature Encryption"
        stepTitle.font = UIFont.boldSystemFont(ofSize: 20)
        
        stepTitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stepTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stepTitle.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 24),
        ])
    }
                
    private func configureStepDescription() {
        stepDescription.backgroundColor = UIColor(hexString: Colors.background.rawValue, alpha: 1) ?? .white
        let description = "The extracted features are encrypted with Ring-LWE public key, to form 2 vectors of length 512."
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
    
    private func configureFeatureTableView() {
        featuresTableView.delegate = self
        featuresTableView.dataSource = self
        featuresTableView.backgroundColor = UIColor(hexString: Colors.blue.rawValue, alpha: 0.3) ?? .systemGray6
        featuresTableView.layer.cornerRadius = 10
        featuresTableView.allowsSelection = false
        featuresTableView.register(CustomCell.self, forCellReuseIdentifier: CustomCell.identifier)
        
        featuresTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            featuresTableView.centerXAnchor.constraint(equalTo: view.leadingAnchor, constant: self.screenWidth/7.2),
            featuresTableView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: self.screenHeight/4.66),
            featuresTableView.widthAnchor.constraint(equalToConstant: self.screenWidth/4.3),
            featuresTableView.heightAnchor.constraint(equalToConstant: self.screenHeight/3.73)
        ])
    }
    
    private func configureArrow() {
        let rightArrowConfig = UIImage.SymbolConfiguration(pointSize: 50)
        rightArrow.image = UIImage(systemName: "arrow.forward", withConfiguration: rightArrowConfig)
        rightArrow.tintColor = .black
        
        rightArrow.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rightArrow.centerXAnchor.constraint(equalTo: view.leadingAnchor, constant: self.screenWidth/2.91),
            rightArrow.centerYAnchor.constraint(equalTo: featuresTableView.centerYAnchor)
        ])
    }
    
    private func configureEncryptedFeature1TableView() {
        encryptedFeature1TableView.delegate = self
        encryptedFeature1TableView.dataSource = self
        encryptedFeature1TableView.backgroundColor = UIColor(hexString: Colors.blue.rawValue, alpha: 0.3) ?? .systemGray6
        encryptedFeature1TableView.layer.cornerRadius = 10
        encryptedFeature1TableView.allowsSelection = false
        encryptedFeature1TableView.register(CustomCell.self, forCellReuseIdentifier: CustomCell.identifier)
        
        encryptedFeature1TableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            encryptedFeature1TableView.centerXAnchor.constraint(equalTo: view.trailingAnchor, constant: -self.screenWidth/6.4),
            encryptedFeature1TableView.centerYAnchor.constraint(equalTo: featuresTableView.centerYAnchor),
            encryptedFeature1TableView.widthAnchor.constraint(equalToConstant: self.screenWidth/3.8),
            encryptedFeature1TableView.heightAnchor.constraint(equalToConstant: self.screenHeight/3.73)
        ])
    }
    
    private func configureEncryptedFeature2TableView() {
        encryptedFeature2TableView.delegate = self
        encryptedFeature2TableView.dataSource = self
        encryptedFeature2TableView.backgroundColor = UIColor(hexString: Colors.blue.rawValue, alpha: 0.3) ?? .systemGray6
        encryptedFeature2TableView.layer.cornerRadius = 10
        encryptedFeature2TableView.allowsSelection = false
        encryptedFeature2TableView.register(CustomCell.self, forCellReuseIdentifier: CustomCell.identifier)
        
        encryptedFeature2TableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            encryptedFeature2TableView.centerXAnchor.constraint(equalTo: view.trailingAnchor, constant: -self.screenWidth/2.2),
            encryptedFeature2TableView.centerYAnchor.constraint(equalTo: featuresTableView.centerYAnchor),
            encryptedFeature2TableView.widthAnchor.constraint(equalToConstant: self.screenWidth/3.8),
            encryptedFeature2TableView.heightAnchor.constraint(equalToConstant: self.screenHeight/3.73)
        ])
    }

}

extension Step2VC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === featuresTableView {
            return self.features.count
        } else if tableView === encryptedFeature1TableView {
            return self.encryptedFeature1.count
        } else if tableView === encryptedFeature2TableView {
            return self.encryptedFeature2.count
        } else {
            fatalError("Invalid TableView")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === featuresTableView {
            guard let cell = featuresTableView.dequeueReusableCell(withIdentifier: CustomCell.identifier, for: indexPath) as? CustomCell else {  fatalError("The TableView could not dequeue a CustomCell in Step2VC.") }
            let label = self.features[indexPath.row]
            cell.backgroundColor = UIColor(hexString: Colors.blue.rawValue, alpha: 0.3) ?? .white
            cell.configure(label: label)
            return cell
        } else if tableView === encryptedFeature1TableView {
            guard let cell = encryptedFeature1TableView.dequeueReusableCell(withIdentifier: CustomCell.identifier, for: indexPath) as? CustomCell else {  fatalError("The TableView could not dequeue a CustomCell in Step2VC.") }
            let label = self.encryptedFeature1[indexPath.row]
            cell.backgroundColor = UIColor(hexString: Colors.blue.rawValue, alpha: 0.3) ?? .white
            cell.configure(label: label)
            return cell
        } else if tableView === encryptedFeature2TableView {
            guard let cell = encryptedFeature2TableView.dequeueReusableCell(withIdentifier: CustomCell.identifier, for: indexPath) as? CustomCell else {  fatalError("The TableView could not dequeue a CustomCell in Step2VC.") }
            let label = self.encryptedFeature2[indexPath.row]
            cell.backgroundColor = UIColor(hexString: Colors.blue.rawValue, alpha: 0.3) ?? .white
            cell.configure(label: label)
            return cell
        } else {
            fatalError("Invalid TableView")
        }

    }
    
}
