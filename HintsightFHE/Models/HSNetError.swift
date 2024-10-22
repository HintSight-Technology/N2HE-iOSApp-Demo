//
//  HSNetError.swift
//  HintsightFHE
//
//  Created by Luo Kaiwen on 30/7/24.
//

import Foundation


enum HSNetError: String, Error {
    case invalidResponse = "Invalid response from the server. Please try again!"
    case invalidData = "The data received from the server was invalid. Please try again!"
}
