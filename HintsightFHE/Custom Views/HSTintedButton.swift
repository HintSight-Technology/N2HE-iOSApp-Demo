//
//  HSTintedButton.swift
//  HintsightFHE
//
//  Created by Luo Kaiwen on 1/8/24.
//

import UIKit

class HSTintedButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(color: UIColor, title: String, systemImageName: String) {
        self.init(frame: .zero)
        configuration?.baseBackgroundColor = color
        configuration?.baseForegroundColor = color
        configuration?.title = title
        
        if systemImageName != "" {
            configuration?.image = UIImage(systemName: systemImageName)
            configuration?.imagePadding = 7
            configuration?.imagePlacement = .leading
        }
    }
    
    private func configure() {
        configuration = .tinted()
        configuration?.cornerStyle = .medium
        translatesAutoresizingMaskIntoConstraints = false
    }
    
}
