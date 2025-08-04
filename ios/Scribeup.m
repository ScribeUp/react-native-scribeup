#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTViewManager.h>

@interface RCT_EXTERN_MODULE(Scribeup, RCTEventEmitter)

RCT_EXTERN_METHOD(presentWithUrl:(NSString *)url
                  withProductName:(NSString *)productName
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end

@interface RCT_EXTERN_MODULE(ScribeupWidgetViewManager, RCTViewManager)

RCT_EXPORT_VIEW_PROPERTY(url, NSString)
RCT_EXTERN_METHOD(reload:(nonnull NSNumber *)reactTag)
RCT_EXTERN_METHOD(loadURL:(nonnull NSNumber *)reactTag url:(NSString *)url)

@end
