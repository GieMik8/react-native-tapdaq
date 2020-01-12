#import "RNTapdaq.h"
#import <Tapdaq/Tapdaq.h>

@implementation RNTapdaq

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(initialize:(NSString *)applicationId
                  clientKey:(NSString *)clientKey
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    TDProperties *tdProperties = [[TDProperties alloc] init];
    [Tapdaq.sharedSession setApplicationId:applicationId clientKey:clientKey properties:tdProperties];
}

@end
