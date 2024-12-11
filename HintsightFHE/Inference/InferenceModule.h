//
//  InferenceModule.h
//  HintsightFHE
//
//  Created by Luo Kaiwen on 19/7/24.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN 

@interface InferenceModule : NSObject

- (nullable instancetype)initWithFileAtPath:(NSString*)filePath
    NS_SWIFT_NAME(init(fileAtPath:))NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (nullable NSArray<NSArray<NSNumber*>*>*)audioFeatureExtract:(const void*)wavBuffer withLen:(int)bufLength fromFile:(NSString*)filePath NS_SWIFT_NAME(audioFeatureExtract(wavBuffer:bufLength:filePath:));
- (nullable NSString*)SVDecrpytVector:(NSArray<NSNumber*>*)encVector
                                   :(NSString*)filePath NS_SWIFT_NAME(audioDecrypt(vector:fileAtPath:));

- (nullable NSArray<NSNumber*>*)imgFeatureExtract:(void*)imageBuffer NS_SWIFT_NAME(imgFeatureExtract(image:));
- (nullable NSArray<NSArray<NSNumber*>*>*)imgFeatureExtractandEnc:(void*)imageBuffer
                                                           :(NSString*)pkFilePath NS_SWIFT_NAME(imgFeatureExtractandEnc(image:pkFilePath:));
- (nullable NSString*)FVDecrpytVector:(NSArray<NSNumber*>*)encVector
                                   :(NSString*)filePath NS_SWIFT_NAME(imgDecrypt(vector:fileAtPath:));
//- (nullable NSArray<NSNumber*>*)FVDecrpytVector:(NSArray<NSNumber*>*)encVector
//                                   :(NSString*)filePath NS_SWIFT_NAME(imgDecrypt(vector:fileAtPath:));

@end

NS_ASSUME_NONNULL_END
