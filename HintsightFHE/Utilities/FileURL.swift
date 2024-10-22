//
//  FileURL.swift
//  HintsightFHE
//
//  Created by Luo Kaiwen on 6/8/24.
//

import Foundation


func getDocumentsDirectory() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
}
