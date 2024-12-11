//
//  Step4VC.swift
//  HintsightFHE
//
//  Created by Luo Kaiwen on 6/12/24.
//

import UIKit

class Step4VC: UIViewController {

    private let stepTitle = UILabel()
    private let stepDescription = UITextView()
    private let encryptedResultTableView = UITableView()
    private let decryptedResultTableView = UITableView()
    private let rightArrow = UIImageView()
    
    private var screenHeight = 0.0
    private var screenWidth = 0.0
    private var encryptedResult: [String] = []
    private var decryptedResult: [String] = []
    
    init(encryptedResult: String = "", decryptedResult: String = "",
         screenHeight: CGFloat = 0.0, screenWidth: CGFloat = 0.0) {
        super.init(nibName: nil, bundle: nil)
        self.encryptedResult = encryptedResult.split(separator: ",").map{ String($0) }
        self.decryptedResult = decryptedResult.split(separator: ",").map{ String($0) }
        self.screenHeight = screenHeight
        self.screenWidth = screenWidth
        print(self.encryptedResult)
        print(self.decryptedResult)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexString: Colors.background.rawValue, alpha: 1) ?? .white
        view.addSubviews(stepTitle, stepDescription, encryptedResultTableView, decryptedResultTableView,
                         rightArrow)
        
        configureStepTitle()
        configureStepDescription()
        configureEncryptedResultTableView()
        configureDecryptedResultTableView()
        configureArrow()
    }

    private func configureStepTitle() {
        stepTitle.textColor = UIColor(hexString: Colors.blue.rawValue, alpha: 1) ?? .black
        stepTitle.text = "Step 4: Result Decryption"
        stepTitle.font = UIFont.boldSystemFont(ofSize: 20)
        
        stepTitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stepTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stepTitle.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
                
    private func configureStepDescription() {
        stepDescription.backgroundColor = UIColor(hexString: Colors.background.rawValue, alpha: 1) ?? .white
        let description = "The encrypted result received from the cloud server will be decrypted locally on the device. If the first value is smaller than the second value, the verification will be a match, otherwise, it will fail."
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
    
    private func configureEncryptedResultTableView() {
        encryptedResultTableView.delegate = self
        encryptedResultTableView.dataSource = self
        encryptedResultTableView.backgroundColor = UIColor(hexString: Colors.blue.rawValue, alpha: 0.3) ?? .systemGray6
        encryptedResultTableView.layer.cornerRadius = 10
        encryptedResultTableView.allowsSelection = false
        encryptedResultTableView.register(CustomCell.self, forCellReuseIdentifier: CustomCell.identifier)
        
        encryptedResultTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            encryptedResultTableView.centerXAnchor.constraint(equalTo: view.leadingAnchor, constant: self.screenWidth/4.3), //100
            encryptedResultTableView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                              constant: self.screenHeight/4.66), //200
            encryptedResultTableView.widthAnchor.constraint(equalToConstant: self.screenWidth/3.5), //120
            encryptedResultTableView.heightAnchor.constraint(equalToConstant: self.screenHeight/3.73) //250
        ])
    }
    
    private func configureArrow() {
        let rightArrowConfig = UIImage.SymbolConfiguration(pointSize: 50)
        rightArrow.image = UIImage(systemName: "arrow.forward", withConfiguration: rightArrowConfig)
        rightArrow.tintColor = .black
        
        rightArrow.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rightArrow.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            rightArrow.centerYAnchor.constraint(equalTo: encryptedResultTableView.centerYAnchor)
        ])
    }
    
    private func configureDecryptedResultTableView() {
        decryptedResultTableView.delegate = self
        decryptedResultTableView.dataSource = self
        decryptedResultTableView.backgroundColor = UIColor(hexString: Colors.blue.rawValue, alpha: 0.3) ?? .systemGray6
        decryptedResultTableView.layer.cornerRadius = 10
        decryptedResultTableView.allowsSelection = false
        decryptedResultTableView.register(CustomCell.self, forCellReuseIdentifier: CustomCell.identifier)
        
        decryptedResultTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            decryptedResultTableView.centerXAnchor.constraint(equalTo: view.trailingAnchor, constant: -self.screenWidth/4.3), //-100
            decryptedResultTableView.centerYAnchor.constraint(equalTo: encryptedResultTableView.centerYAnchor),
            decryptedResultTableView.widthAnchor.constraint(equalToConstant: self.screenWidth/3.5), //120
            decryptedResultTableView.heightAnchor.constraint(equalToConstant: self.screenHeight/11.65) //80
        ])
    }
    
}

extension Step4VC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === encryptedResultTableView {
            return self.encryptedResult.count
        } else if tableView === decryptedResultTableView {
            return self.decryptedResult.count
        } else {
            fatalError("Invalid TableView")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === encryptedResultTableView {
            guard let cell = encryptedResultTableView.dequeueReusableCell(withIdentifier: CustomCell.identifier, for: indexPath) as? CustomCell else {  fatalError("The TableView could not dequeue a CustomCell in Step4VC.") }
            let label = self.encryptedResult[indexPath.row]
            cell.backgroundColor = UIColor(hexString: Colors.blue.rawValue, alpha: 0.3) ?? .white
            cell.configure(label: label)
            return cell
        } else if tableView === decryptedResultTableView {
            guard let cell = decryptedResultTableView.dequeueReusableCell(withIdentifier: CustomCell.identifier, for: indexPath) as? CustomCell else {  fatalError("The TableView could not dequeue a CustomCell in Step4VC.") }
            let label = self.decryptedResult[indexPath.row]
            cell.backgroundColor = UIColor(hexString: Colors.blue.rawValue, alpha: 0.3) ?? .white
            cell.configure(label: label)
            return cell
        } else {
            fatalError("Invalid TableView")
        }
    }
    
}
