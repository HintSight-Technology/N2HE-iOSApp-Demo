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
    let verifyButton = HSTintedButton(color: .systemGreen, title: "Verify", systemImageName: "")
    let resetButton = HSTintedButton(color: .systemPink, title: "Reset", systemImageName: "")
    let usernameTextField = HSTextField(text: "Enter your name here")
    
    var image: UIImage?
    var username: String = ""
    private let inputWidth: CGFloat = 160
    private let inputHeight: CGFloat = 160
    private let baseUrl = "https://fr-demo-03.hintsight.com"
    private var extractor = FeatureExtractor()
    private var cancellables = Set<AnyCancellable>()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Facial Verification"
        view.addSubviews(imageView, cameraButton, usernameTextField, verifyButton, resetButton)
        
        configureImageView()
        configureCameraButton()
        configureUsernameTextField()
        configureVerifyButton()
        configureResetButton()
        setupKeyboardHiding()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func verifyTapped(_ sender: Any) {
        self.verifyButton.isEnabled = false
        self.verifyButton.configuration?.image = nil
        self.verifyButton.configuration?.title = "Verifying..."
        let dateID = setDateFormat(as: "MM-dd-yyy_HH:mm:ss:SSS")
        
        guard let rlwePkPath = Bundle.main.path(forResource: "rlwe_pk", ofType: "txt") else {
            fatalError("Can't find rlwe_pk.txt file!")
        }
        guard let rlweSkPath = Bundle.main.path(forResource: "rlwe_sk", ofType: "txt") else {
            fatalError("Can't find rlwe_sk.txt file!")
        }

        let resizedImage = image!.resized(to: CGSize(width: inputWidth, height: inputHeight))
        guard var pixelBuffer = resizedImage.normalized() else {
            return
        }
        
        DispatchQueue.global().async {
            guard let encFeatureVectors = self.extractor.module.imgFeatureExtract(image: &pixelBuffer, pkFilePath: rlwePkPath) else {
                return
            }
            
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
                        self.verifyButton.configuration?.title = "Verify"
                        print("end of verification...")
                    }
                }, receiveValue: { value in
                    DispatchQueue.main.async() {
                        print("value")
                        let vector: [Int64] = value.result
                        let matchResult = self.extractor.module.imgDecrypt(vector: vector.map { NSNumber(value: $0) }, fileAtPath: rlweSkPath)
                        
                        if (matchResult == "no") {
                            let message = "Facial biometrics is not a match with " + self.username + ". Please try again!"
                            self.presentHSAlert(title: "Verification Failed", message: message, buttonLabel: "OK", titleLabelColor: .systemPink)
                        } else {
                            let message = "Facial biometrics is a match with " + self.username + "!"
                            self.presentHSAlert(title: "Verification Passed!", message: message, buttonLabel: "OK", titleLabelColor: .systemGreen)
                        }
                    }
                })
                .store(in: &self.cancellables)

            } //post request
            task.resume()
        }
    }
    
    @objc func cameraTapped(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        self.present(imagePickerController, animated: true)
    }
    
    @objc func resetTapped(_ sender: UIButton) {
        resetButton.isHidden = true
        
        cameraButton.isHidden = false
        verifyButton.isEnabled = false

        imageView.image = nil
        username = ""
        usernameTextField.text = ""
        usernameTextField.placeholder = "Enter your name here"
    }
    
    
    
    private func configureImageView() {
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray4
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 200),
            imageView.widthAnchor.constraint(equalToConstant: 320),
            imageView.heightAnchor.constraint(equalToConstant: 320)
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
    
    private func configureResetButton() {
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        resetButton.isHidden = true

        NSLayoutConstraint.activate([
            resetButton.topAnchor.constraint(equalTo: verifyButton.bottomAnchor, constant: 30),
            resetButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100),
            resetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100),
            resetButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureUsernameTextField() {
        usernameTextField.delegate = self
        NSLayoutConstraint.activate([
            usernameTextField.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 40),
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            usernameTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureVerifyButton() {
        verifyButton.addTarget(self, action: #selector(verifyTapped), for: .touchUpInside)
        verifyButton.isEnabled = false
        
        NSLayoutConstraint.activate([
            verifyButton.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 40),
            verifyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100),
            verifyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100),
            verifyButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

}
