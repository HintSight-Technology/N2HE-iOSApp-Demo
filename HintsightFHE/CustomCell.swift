//
//  CustomCell.swift
//  HintsightFHE
//
//  Created by Luo Kaiwen on 4/12/24.
//

import UIKit

class CustomCell: UITableViewCell {
    
    static let identifier = "CustomCell"
    
    private let featureLabel : UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.text = "Error"
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.configureLabels()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(label: String) {
        self.featureLabel.text = label
    }
    
    private func configureLabels() {
        self.addSubview(featureLabel)
        featureLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            featureLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            featureLabel.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor),
            featureLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            featureLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
    }
    
}
