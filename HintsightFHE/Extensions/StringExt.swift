//
//  StringExt.swift
//  HintsightFHE
//
//  Created by Luo Kaiwen on 16/7/24.
//

import Foundation


extension String {
    
    func strAppendPathComponent(path: String) -> String {
        let s = self as NSString
        return s.appendingPathComponent(path)
    }

}
