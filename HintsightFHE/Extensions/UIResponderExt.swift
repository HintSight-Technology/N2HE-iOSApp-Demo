//
//  UIResponderExt.swift
//  HintsightFHE
//
//  Created by Luo Kaiwen on 17/7/24.
//

import UIKit


extension UIResponder {
    
    private struct Static {
        static weak var responder: UIResponder?
    }
    
    //find current firts responder
    //returns current UIResponder if it exists
    static func currentFirst() -> UIResponder? {
        Static.responder = nil
        UIApplication.shared.sendAction(#selector(UIResponder._trap), to: nil, from: nil, for: nil)
        return Static.responder
    }
    
    @objc private func _trap() {
        Static.responder = self
    }
    
}

