#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(Scribeup, RCTEventEmitter)

RCT_EXTERN_METHOD(presentWithUrl:(NSString *)url
                  withProductName:(NSString *)productName
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end
