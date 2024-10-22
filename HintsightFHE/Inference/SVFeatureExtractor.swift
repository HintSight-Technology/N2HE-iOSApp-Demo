//
//  FeatureExtractor.swift
//  HintsightFHE
//
//  Created by Luo Kaiwen on 19/7/24.
//

import UIKit

class SVFeatureExtractor {
    lazy var module: InferenceModule = {
        let modelName = "wav2vec2_forxvector"
        
        if let filePath = Bundle.main.path(forResource: modelName, ofType: "pt"),
            let module = InferenceModule(fileAtPath: filePath) {
            return module
        } else {
            fatalError("Can't load InferenceModule!")
        }
    }()
}
