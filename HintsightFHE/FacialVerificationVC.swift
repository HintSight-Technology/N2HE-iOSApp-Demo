//
//  FacialVerificationVC.swift
//  HintsightFHE
//
//  Created by Luo Kaiwen on 30/7/24.
//

import UIKit
import Combine

class FacialVerificationVC: UIViewController {

    let imageView = UIImageView()
    let cameraButton = UIButton()
    let verifyButton = HSTintedButton(color: UIColor(hexString: Colors.blue.rawValue, alpha: 1) ?? .systemCyan,
                                      title: "VERIFY", systemImageName: "")
    let resetButton = HSTintedButton(color: UIColor(hexString: Colors.pink.rawValue, alpha: 1) ?? .systemPink,
                                     title: "RESET", systemImageName: "")
    let stepByStepButton = HSTintedButton(color: UIColor(hexString: Colors.blue.rawValue, alpha: 1) ?? .systemPink,
                                          title: "STEP BY STEP", systemImageName: "")
    let usernameTextField = HSTextField(text: "Enter your name here")
    var encFeatureTextView = UITextView()
    var encResultTextView = UITextView()
    
    public var image: UIImage?
    public var username: String = ""
    private var screenHeight = 0.0
    private var screenWidth = 0.0
    private var featureString = ""
    private var encryptedFeatureString = ""
    private var encryptedResultString = ""
    private var decryptedResultString = ""
    private let inputWidth: CGFloat = 160
    private let inputHeight: CGFloat = 160
    private let baseUrl = "https://fr-demo-03.hintsight.com"
    private var extractor = FeatureExtractor()
    private var cancellables = Set<AnyCancellable>()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexString: Colors.background.rawValue, alpha: 1) ?? .white
        navigationController?.navigationBar.prefersLargeTitles = false
//        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(hexString: Colors.blue.rawValue, alpha: 1) ?? .systemCyan]
        navigationController?.navigationBar.tintColor = UIColor(hexString: Colors.blue.rawValue, alpha: 1) ?? .systemCyan
        navigationItem.title = "Facial Verification"
        view.addSubviews(imageView, cameraButton, usernameTextField, verifyButton, resetButton, stepByStepButton)
        
        configureImageView()
        configureCameraButton()
        configureUsernameTextField()
        configureVerifyButton()
        configureResetButton()
        configureStepByStepButton()
        setupKeyboardHiding()
    }
    
    init(screenWidth: CGFloat = 0.0, screenHeight: CGFloat = 0.0) {
        super.init(nibName: nil, bundle: nil)
        self.screenWidth = screenWidth
        self.screenHeight = screenHeight
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func verifyTapped(_ sender: Any) {
        if (username.isEmpty) {
            let message = "Please press done after username is entered."
            self.presentHSAlert(title: "Empty Username", message: message, buttonLabel: "OK", titleLabelColor: .systemPink)
        } else {
            self.verifyButton.isEnabled = false
            self.verifyButton.configuration?.image = nil
            self.verifyButton.configuration?.title = "VERIFYING..."
            let dateID = setDateFormat(as: "MM-dd-yyy_HH:mm:ss:SSS")
            
            let resizedImage = image!.resized(to: CGSize(width: inputWidth, height: inputHeight))
            guard var pixelBuffer = resizedImage.normalized() else { return }
            
            guard let rlwePkPath = Bundle.main.path(forResource: "rlwe_pk", ofType: "txt") else {
                fatalError("Can't find rlwe_pk.txt file!")}
            guard let rlweSkPath = Bundle.main.path(forResource: "rlwe_sk", ofType: "txt") else {
                fatalError("Can't find rlwe_sk.txt file!")}

            DispatchQueue.global().async {
                guard let featureVectors = self.extractor.module.imgFeatureExtract(image: &pixelBuffer) else { return }
                guard let encFeatureVectors = self.extractor.module.imgFeatureExtractandEnc(image: &pixelBuffer, pkFilePath: rlwePkPath) else {
                    return
                }
                
                self.featureString = (featureVectors.map{ $0.stringValue }).joined(separator: ",")
                self.encryptedFeatureString = (encFeatureVectors[0].map{ $0.stringValue }).joined(separator: ",")
                self.encryptedFeatureString += ","
                self.encryptedFeatureString += (encFeatureVectors[1].map{ $0.stringValue }).joined(separator: ",")
                
                let body = [
                    "id": dateID,
                    "name": self.username,
                    "feature_vector": encFeatureVectors
                ] as [String : Any]
                
                // ======================== POST REQUEST ========================
                var request = URLRequest(url: URL(string: self.baseUrl)!)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
                
                let task = URLSession.shared.dataTask(with: request) {
                    data, _, error in
                    guard let data = data, error == nil else {
                        return
                    }
                    
                    do {
                        _ = try JSONDecoder().decode(UserEncBio.self, from: data)
                        print("POST SUCCESS")
                    } catch {
                        DispatchQueue.main.async() {
                            self.presentHSAlert(title: "Something Went Wrong", message: HSNetError.invalidResponse.rawValue, buttonLabel: "OK", titleLabelColor: .black)
                        }
                    }
                    
                    // ===================== GET REQUEST ========================
                    let urlString = self.baseUrl + "/" + self.username + "_" + dateID + ".json"
                    let url = URL(string: urlString)!
                    typealias DataTaskOutput = URLSession.DataTaskPublisher.Output
                    
                    let dataTaskPublisher = URLSession.shared.dataTaskPublisher(for: url)
                        .tryMap({ (dataTaskOutput: DataTaskOutput) -> Result<DataTaskOutput, Error> in
                            guard let httpResponse = dataTaskOutput.response as? HTTPURLResponse else {
                                return .failure(HSNetError.invalidResponse)
                            }
                            
                            if httpResponse.statusCode == 404 {
                                throw HSNetError.invalidData
                            }
                            
                            return .success(dataTaskOutput)
                        })
                    
                    dataTaskPublisher
                        .catch({ (error: Error) -> AnyPublisher<Result<URLSession.DataTaskPublisher.Output, Error>, Error> in
                            
                            switch error {
                            case HSNetError.invalidData:
                                print("Received a retryable error")
                                return Fail(error: error)
                                    .delay(for: 0.05, scheduler:  DispatchQueue.global())
                                    .eraseToAnyPublisher()
                            default:
                                print("Received a non-retryable error")
                                return Just(.failure(error))
                                    .setFailureType(to: Error.self)
                                    .eraseToAnyPublisher()
                            }
                        })
                            .retry(50)
                            .tryMap({ result in
                                let response = try result.get()
                                let json = try JSONDecoder().decode(UserEncResult.self, from: response.data)
                                return json
                            })
                                .sink(receiveCompletion:  { _ in
                                    DispatchQueue.main.async {
                                        self.verifyButton.isEnabled = true
                                        self.verifyButton.configuration?.title = "VERIFY"
                                        self.stepByStepButton.isEnabled = true
                                        print("end of verification...")
                                    }
                                }, receiveValue: { value in
                                    DispatchQueue.main.async() {
                                        print("value")
                                        let vector: [Int64] = value.result
                                        self.encryptedResultString = vector.map{ String($0) }.joined(separator: ",")
                                        let matchResult = self.extractor.module.imgDecrypt(vector: vector.map { NSNumber(value: $0) }, fileAtPath: rlweSkPath)
                                        self.decryptedResultString = matchResult ?? ""
                                        let result = matchResult?.split(separator: ",").map{ Int($0) }
                                        
                                        if (result![0]! >= result![1]!) {
                                            let message = "Facial biometrics is not a match with " + self.username + ". Please try again!"
                                            self.presentHSAlert(title: "Verification Failed", message: message, buttonLabel: "OK", titleLabelColor: .systemPink)
                                        } else {
                                            let message = "Facial biometrics is a match with " + self.username + "!"
                                            self.presentHSAlert(title: "Verification Passed!", message: message, buttonLabel: "OK", titleLabelColor: .systemGreen)
                                        }

//                                        if (matchResult == "no") {
//                                            let message = "Facial biometrics is not a match with " + self.username + ". Please try again!"
//                                            self.presentHSAlert(title: "Verification Failed", message: message, buttonLabel: "OK", titleLabelColor: .systemPink)
//                                        } else {
//                                            let message = "Facial biometrics is a match with " + self.username + "!"
//                                            self.presentHSAlert(title: "Verification Passed!", message: message, buttonLabel: "OK", titleLabelColor: .systemGreen)
//                                        }
                                    }
                                })
                                    .store(in: &self.cancellables)
                                
                } //post request
                task.resume()
            }
        }
    }
    
    @objc func cameraTapped(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        self.present(imagePickerController, animated: true)
    }
    
    @objc func resetTapped(_ sender: UIButton) {
        cameraButton.isHidden = false
        resetButton.isEnabled = false
        verifyButton.isEnabled = false
        stepByStepButton.isEnabled = false

        imageView.image = nil
        username = ""
        usernameTextField.text = ""
        usernameTextField.placeholder = "Enter your name here"
    }
    
    @objc func pushStepByStepVC(_ sender: UIButton) {
        let stepbyStepPVC = StepbyStepPVC(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        stepbyStepPVC.face = image
        stepbyStepPVC.featuresString = featureString
        stepbyStepPVC.encryptedFeaturesString = encryptedFeatureString
        stepbyStepPVC.screenWidth = screenWidth
        stepbyStepPVC.screenHeight = screenHeight
        stepbyStepPVC.encryptedResultString = encryptedResultString
        stepbyStepPVC.decryptedResultString = decryptedResultString
        navigationController?.pushViewController(stepbyStepPVC, animated: true)
    }

    
    
    private func configureImageView() {
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 7
        imageView.backgroundColor = UIColor(hexString: Colors.blue.rawValue, alpha: 0.3) ?? .systemGray6
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: self.screenHeight/6.21), //150
            imageView.widthAnchor.constraint(equalToConstant: min(self.screenHeight/2.9, self.screenWidth/1.34)), //320
            imageView.heightAnchor.constraint(equalToConstant: min(self.screenHeight/2.9, self.screenWidth/1.34)) //320
        ])
    }
    
    private func configureCameraButton() {
        cameraButton.addTarget(self, action: #selector(cameraTapped), for: .touchUpInside)
        
        let cameraConfig = UIImage.SymbolConfiguration(pointSize: 30)
        cameraButton.configuration = .filled()
        cameraButton.configuration?.baseBackgroundColor = .clear
        cameraButton.configuration?.image = UIImage(systemName: "camera", withConfiguration: cameraConfig)

        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cameraButton.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            cameraButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }
    
    private func configureUsernameTextField() {
        usernameTextField.delegate = self
        usernameTextField.layer.masksToBounds = true
        usernameTextField.layer.cornerRadius = 26
        usernameTextField.layer.borderWidth = 1
        usernameTextField.backgroundColor = UIColor(hexString: Colors.blue.rawValue, alpha: 0.3) ?? .lightGray
        usernameTextField.layer.borderColor = UIColor(hexString: Colors.background.rawValue, alpha: 1)?.cgColor
        
        NSLayoutConstraint.activate([
            usernameTextField.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: self.screenHeight/46.6), //20
            usernameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            usernameTextField.widthAnchor.constraint(equalToConstant: min(self.screenHeight/2.9, self.screenWidth/1.34)), //320
            usernameTextField.heightAnchor.constraint(equalToConstant: self.screenHeight/18.64) //50
        ])
    }
        
    private func configureResetButton() {
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        resetButton.isEnabled = false

        NSLayoutConstraint.activate([
            resetButton.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: self.screenHeight/37.28), //25
            resetButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: self.screenWidth/4.3), //100
            resetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -self.screenWidth/4.3), //-100
            resetButton.heightAnchor.constraint(equalToConstant: self.screenHeight/18.64) //50
        ])
    }
    
    private func configureVerifyButton() {
        verifyButton.addTarget(self, action: #selector(verifyTapped), for: .touchUpInside)
        verifyButton.isEnabled = false
        
        NSLayoutConstraint.activate([
            verifyButton.topAnchor.constraint(equalTo: resetButton.bottomAnchor, constant: self.screenHeight/37.28), //25
            verifyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: self.screenWidth/4.3), //100
            verifyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -self.screenWidth/4.3), //-100
            verifyButton.heightAnchor.constraint(equalToConstant: self.screenHeight/18.64) //50
        ])
    }
    
    private func configureStepByStepButton() {
        stepByStepButton.addTarget(self, action: #selector(pushStepByStepVC), for: .touchUpInside)
        stepByStepButton.isEnabled = false
        
        NSLayoutConstraint.activate([
            stepByStepButton.topAnchor.constraint(equalTo: verifyButton.bottomAnchor, constant: self.screenHeight/37.28), //25
            stepByStepButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: self.screenWidth/4.3), //100
            stepByStepButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -self.screenWidth/4.3), //-100
            stepByStepButton.heightAnchor.constraint(equalToConstant: self.screenHeight/18.64) //50
        ])
    }

}
