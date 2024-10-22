//
//  DateFormat.swift
//  HintsightFHE
//
//  Created by Luo Kaiwen on 6/8/24.
//

import Foundation


func setDateFormat(as format: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: Date())
}
