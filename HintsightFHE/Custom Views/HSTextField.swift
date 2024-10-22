//
//  HSTextField.swift
//  HintsightFHE
//
//  Created by Luo Kaiwen on 1/8/24.
//

import UIKit

class HSTextField: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(text: String) {
        super.init(frame: .zero)
        self.placeholder = text
        configure()
    }
    
    private func configure() {
        self.layer.masksToBounds = true
        self.borderStyle = .roundedRect
        self.textAlignment = .center
        
        self.returnKeyType = .done
        self.autocapitalizationType = .words
        self.autocorrectionType = .no
        
        translatesAutoresizingMaskIntoConstraints = false
    }

}
