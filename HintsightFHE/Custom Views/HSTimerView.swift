//
//  HSTimerView.swift
//  HintsightFHE
//
//  Created by Luo Kaiwen on 2/8/24.
//

import UIKit

class HSTimerView: UITextView {

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer:  textContainer)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(time: String) {
        super.init(frame: .zero, textContainer: nil)
        self.text = time
        configure()
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
    }

}
