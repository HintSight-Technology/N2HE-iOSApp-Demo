//
//  DoubleExt.swift
//  HintsightFHE
//
//  Created by Luo Kaiwen on 2/8/24.
//

import Foundation


extension Double {
    
    var toTimeString: String {
        let seconds: Int = Int(self.truncatingRemainder(dividingBy: 60.0))
        let minutes: Int = Int(self / 60.0)
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
}
