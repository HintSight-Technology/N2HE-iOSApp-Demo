//
//  UserEncBio.swift
//  HintsightFHE
//
//  Created by Luo Kaiwen on 30/7/24.
//

import Foundation


struct UserEncBio: Codable {
    let id: String
    let name: String
    let feature_vector: [[Int64]]
}
