//
//  HSAlertVC.swift
//  HintsightFHE
//
//  Created by Luo Kaiwen on 6/8/24.
//

import UIKit

class HSAlertVC: UIViewController {

    let containerView = HSAlertContainerView()
    let titleLabel = HSTitleLabel(textAlignment: .center, fontSize: 20)
    let messageLabel = HSBodyLabel(textAlignment: .center)
    let tapButton = HSTintedButton(color: .systemBlue, title: "OK", systemImageName: "")
    
    var alertTitle: String?
    var message: String?
    var buttonLabel: String?
    var titleLabelColor: UIColor?
    
    let padding: CGFloat = 20
    
    init(title: String, message: String, buttonLabel: String, titleLabelColor: UIColor) {
        super.init(nibName: nil, bundle: nil)
        self.alertTitle = title
        self.message = message
        self.buttonLabel = buttonLabel
        self.titleLabelColor = titleLabelColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        view.addSubviews(containerView, titleLabel, messageLabel, tapButton)
        
        configureContainerView()
        configureMessageLabel()
        configureTapButton()
        configureTitleLabel()
    }

    func configureContainerView() {
        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 280),
            containerView.heightAnchor.constraint(equalToConstant: 220)
        ])
    }
    
    func configureTitleLabel() {
        titleLabel.textColor = self.titleLabelColor
        titleLabel.text = alertTitle ?? "Something went wrong"
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            titleLabel.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    func configureTapButton() {
        tapButton.setTitle(buttonLabel ?? "OK", for: .normal)
        tapButton.addTarget(self, action: #selector(dismissAlertVC), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            tapButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -padding),
            tapButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            tapButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            tapButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func configureMessageLabel() {
        messageLabel.text = message ?? "Unable to proceed with request"
        messageLabel.numberOfLines = 4
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            messageLabel.bottomAnchor.constraint(equalTo: tapButton.topAnchor, constant: -12)
        ])
    }
    
    @objc func dismissAlertVC() {
        dismiss(animated: true)
    }
    
}
