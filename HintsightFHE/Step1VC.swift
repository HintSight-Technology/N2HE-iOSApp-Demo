//
//  Step1VC.swift
//  HintsightFHE
//
//  Created by Luo Kaiwen on 3/12/24.
//

import UIKit

class Step1VC: UIViewController {

    private let facialVerificationVC = FacialVerificationVC()
    private let faceImage = UIImageView()
    private let stepTitle = UILabel()
    private let rightArrow = UIImageView()
    private let featureTableView = UITableView()
    private let stepDescription = UITextView()
    
    private var screenHeight = 0.0
    private var screenWidth = 0.0
    private var face: UIImage?
    private var features: [String] = []
    
    init(face: UIImage? = nil, feature: String = "", screenHeight: CGFloat = 0.0, screenWidth: CGFloat = 0.0) {
        super.init(nibName: nil, bundle: nil)
        self.face = face
        self.features = feature.split(separator: ",").map{ String($0) }
        self.screenHeight = screenHeight
        self.screenWidth = screenWidth
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexString: Colors.background.rawValue, alpha: 1) ?? .white
        view.addSubviews(faceImage, stepTitle, rightArrow, featureTableView, stepDescription)
        
        configureFaceImage()
        configureStepTitle()
        configureArrow()
        configureFeatureTableView()
        configureStepDescription()
    }
    
    private func configureFaceImage() {
        faceImage.image = face
        faceImage.contentMode = .scaleAspectFit
        faceImage.clipsToBounds = true
        faceImage.layer.cornerRadius = 7
        
        faceImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            faceImage.centerXAnchor.constraint(equalTo: view.leadingAnchor, constant: self.screenWidth/4.3), //100
            faceImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: self.screenHeight/4.66), //200
            faceImage.widthAnchor.constraint(equalToConstant: max(self.screenWidth/4.3, self.screenHeight/9.3)), //100
            faceImage.heightAnchor.constraint(equalToConstant: max(self.screenWidth/4.3, self.screenHeight/9.3)) //100
        ])
    }
    
    private func configureStepTitle() {
        stepTitle.textColor = UIColor(hexString: Colors.blue.rawValue, alpha: 1) ?? .black
        stepTitle.text = "Step 1: Feature Extraction"
        stepTitle.font = UIFont.boldSystemFont(ofSize: 20)
        
        stepTitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stepTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stepTitle.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 24),
        ])
    }
    
    private func configureArrow() {
        let rightArrowConfig = UIImage.SymbolConfiguration(pointSize: 50)
        rightArrow.image = UIImage(systemName: "arrow.forward", withConfiguration: rightArrowConfig)
        rightArrow.tintColor = .black
        
        rightArrow.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rightArrow.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            rightArrow.centerYAnchor.constraint(equalTo: faceImage.centerYAnchor)
        ])
    }
        
    private func configureFeatureTableView() {
        featureTableView.delegate = self
        featureTableView.dataSource = self
        featureTableView.backgroundColor = UIColor(hexString: Colors.blue.rawValue, alpha: 0.3) ?? .systemGray6
        featureTableView.layer.cornerRadius = 10
        featureTableView.allowsSelection = false
        featureTableView.register(CustomCell.self, forCellReuseIdentifier: CustomCell.identifier)
        
        featureTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            featureTableView.centerXAnchor.constraint(equalTo: view.trailingAnchor, constant: -self.screenWidth/4.3), //-100
            featureTableView.centerYAnchor.constraint(equalTo: faceImage.centerYAnchor),
            featureTableView.widthAnchor.constraint(equalToConstant: self.screenWidth/3.5), //120
            featureTableView.heightAnchor.constraint(equalToConstant: self.screenHeight/3.73) //250
        ])
    }
    
    private func configureStepDescription() {
        stepDescription.backgroundColor = UIColor(hexString: Colors.background.rawValue, alpha: 1) ?? .white
        let description = "Features of the face image are extracted using feature extractor. The output is a vector of length 512."
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
            stepDescription.widthAnchor.constraint(equalToConstant: self.screenWidth/1.43), //300
            stepDescription.heightAnchor.constraint(equalToConstant: self.screenHeight/3.73) //250
        ])
    }

}

extension Step1VC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.features.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = featureTableView.dequeueReusableCell(withIdentifier: CustomCell.identifier, for: indexPath) as? CustomCell else {  fatalError("The TableView could not dequeue a CustomCell in Step1VC.") }
        
        let label = self.features[indexPath.row]
        cell.backgroundColor = UIColor(hexString: Colors.blue.rawValue, alpha: 0.3) ?? .white
        cell.configure(label: label)
        
        return cell
    }
    
}
