//
//  InferenceModule.mm
//  HintsightFHE
//
//  Created by Luo Kaiwen on 19/7/24.
//

#import "InferenceModule.h"
#import <Libtorch-Lite/Libtorch-Lite.h>
#include "Encrypt.h"
#include "Decrypt.h"

using namespace std;

const int inputWidth = 160;
const int inputHeight = 160;
const int outputDim = 512;
const int outputRow = 2;
const int encDim = 1024;


@implementation InferenceModule {
    @protected torch::jit::mobile::Module _impl;
}


- (nullable instancetype)initWithFileAtPath:(NSString*)filePath {
    self = [super init];
    if (self) {
        try {
            auto qengines = at::globalContext().supportedQEngines();
            if (std::find(qengines.begin(), qengines.end(), at::QEngine::QNNPACK) != qengines.end()) {
                at::globalContext().setQEngine(at::QEngine::QNNPACK);
            }
            _impl = torch::jit::_load_for_mobile(filePath.UTF8String);
        } catch (const std::exception& exception) {
            NSLog(@"%s", exception.what());
            return nil;
        }
    }
    return self;
}

- (NSArray<NSArray<NSNumber*>*>*)audioFeatureExtract:(const void*)wavBuffer withLen:(int)bufLength fromFile:(NSString*)filePath {
    try {
        at::Tensor tensorWavInput = torch::from_blob((void*)wavBuffer, {1, bufLength}, at::kFloat);
        
        c10::InferenceMode guard;
        CFTimeInterval startTime = CACurrentMediaTime();
        auto tensorOutput = _impl.forward({ tensorWavInput }).toTensor();
        CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
        NSLog(@"inference time:%f", elapsedTime);

        float* floatBuffer = tensorOutput.data_ptr<float>();
        if (!floatBuffer) {
            return nil;
        }
        
        NSMutableArray* results = [[NSMutableArray alloc] init];
        for (int i = 0; i < outputDim; i++) {
            [results addObject:@(floatBuffer[i])];
        }
        double l2norm = 0;
        for (int i = 0; i < [results count]; i++) {
            l2norm += pow([results[i] doubleValue], 2);
        }
        l2norm = sqrt(l2norm);

        // Test set
        vector<int>  test_vector;
        vector<double> vec;
        int scaler0 = 25;            // scaler for input vector
        int scaler1 = 40;            // Scaler for Weights

        for (int i = 0; i < [results count]; i++) {
            double t_ = [results[i] doubleValue];
            cout << t_<< " ";
            double t = t_ / l2norm * scaler0;
//            cout << t << " "; //print encrypted result vector
            
            int tt = (int)t;
            if (t > 0 && t - tt > 0.5) {
                test_vector.push_back(tt + 1);
            } else if (t < 0 && tt - t > 0.5) {
                test_vector.push_back(tt - 1);
            } else {
                test_vector.push_back(tt);
            }
        }
        cout << endl;

        string file_path = string([filePath UTF8String]);
        
        CFTimeInterval startTime1 = CACurrentMediaTime();
        vector<vector<int64_t>> ct = vectorEnc(test_vector, file_path);
        
        CFTimeInterval elapsedTime1 = CACurrentMediaTime() - startTime1;
        NSLog(@"encryption inference time: %f", elapsedTime1);

        NSMutableArray* outputs = [[NSMutableArray alloc] init];
        for (int i = 0; i < outputRow; i++) {
            NSMutableArray* rows = [[NSMutableArray alloc] init];
            for (int j = 0; j < encDim; j++) {
                NSNumber* ct_value = @(ct[i][j]);
                [rows addObject:ct_value];
            }
            [outputs addObject:rows];
        }
        
        return [outputs copy];
        
    } catch (const std::exception& exception) {
        NSLog(@"%s", exception.what());
    }
    
    return nil;
}

- (NSString*)SVDecrpytVector:(NSArray<NSNumber*>*)encVector :(NSString*)filePath {
    try {
        string file_path = string([filePath UTF8String]);
        vector<int64_t> enc_vector;
        
        for (int i = 0; i < [encVector count]; ++i) {
            int64_t myint64 = [encVector[i] longLongValue];
            enc_vector.push_back(myint64);
        }
        
        string result = audioResultDec(enc_vector, file_path);
        NSString* match_result = [NSString stringWithUTF8String:result.c_str()];
        
        return match_result;
        
    } catch (const std::exception& exception) {
        NSLog(@"%s", exception.what());
    }
    
    return nil;
}


- (NSArray<NSArray<NSNumber*>*>*)imgFeatureExtract:(void*)imageBuffer:(NSString*)pkFilePath {
    try {
        //exposes given data as Tensor without taking ownership of original data
        at::Tensor tensorInput = torch::from_blob(imageBuffer, { 1, 3, inputHeight, inputWidth }, at::kFloat);
        //used when certain operations will have no interactions with autograd; to guard all operations on tensors
        c10::InferenceMode guard;

        CFTimeInterval startTime = CACurrentMediaTime();
        auto tensorOutput = _impl.forward({ tensorInput }).toTensor();
        CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
        NSLog(@"model inference time: %f", elapsedTime);

        float* floatBuffer = tensorOutput.data_ptr<float>();
        if (!floatBuffer) {
            return nil;
        }

        NSMutableArray* results = [[NSMutableArray alloc] init];
        for (int i = 0; i < outputDim; i++) {
          [results addObject:@(floatBuffer[i])];
        }
        
        // normalize l2 norm to 1
        double l2norm = 0;
        for (int i = 0; i < [results count]; i++) {
            l2norm += pow([results[i] doubleValue], 2);
        }
        l2norm = sqrt(l2norm);

        // Test set
        vector<int>  test_vector;
        vector<double> vec;
        int scaler0 = 25;                         // scaler for input vector
        int scaler1 = 40;                       // Scaler for Weights

        for (int i = 0; i < [results count]; i++) {
            double t_ = [results[i] doubleValue];
//            cout << t_<< " ";
            double t = t_ / l2norm * scaler0;
//            cout << t << " "; //print encrypted result vector
            
            int tt = (int)t;
            if (t > 0 && t - tt > 0.5) {
                test_vector.push_back(tt + 1);
            } else if (t < 0 && tt - t > 0.5) {
                test_vector.push_back(tt - 1);
            } else {
                test_vector.push_back(tt);
            }
        }
        cout << endl;
        
        string file_path = string([pkFilePath UTF8String]);
        
        CFTimeInterval startTime1 = CACurrentMediaTime();
        vector<vector<int64_t>> ct = vectorEnc(test_vector, file_path);
        CFTimeInterval elapsedTime1 = CACurrentMediaTime() - startTime1;
        NSLog(@"encryption inference time: %f", elapsedTime1);
        
        NSMutableArray* outputs = [[NSMutableArray alloc] init];
        for (int i = 0; i < outputRow; i++) {
            NSMutableArray* rows = [[NSMutableArray alloc] init];
            for (int j = 0; j < encDim; j++) {
                NSNumber* ct_value = @(ct[i][j]);
                [rows addObject:ct_value];
            }
            [outputs addObject:rows];
        }
//        cout << outputs << endl;
        return [outputs copy];
        
    } catch (const std::exception& exception) {
        NSLog(@"%s", exception.what());
    }
    
    return nil;
}


- (NSString*)FVDecrpytVector:(NSArray<NSNumber*>*)encVector:(NSString*)filePath {
    try {
        string file_path = string([filePath UTF8String]);
        vector<int64_t> enc_vector;
        
        for (int i = 0; i < [encVector count]; ++i) {
            int64_t myint64 = [encVector[i] longLongValue];
            enc_vector.push_back(myint64);
        }
        
        string result = imgResultDec(enc_vector, file_path);
        NSString* match_result = [NSString stringWithUTF8String:result.c_str()];
        
        return match_result;
        
    } catch (const std::exception& exception) {
        NSLog(@"%s", exception.what());
    }
    
    return nil;
}

@end
