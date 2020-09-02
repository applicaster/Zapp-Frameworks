@import React;

@interface RCT_EXTERN_MODULE (ApplicasterIAPBridge, NSObject)

RCT_EXTERN_METHOD(products:(NSArray *)payload
                      resolver:(RCTPromiseResolveBlock)resolver
                          rejecter:(RCTPromiseRejectBlock)rejecter);

RCT_EXTERN_METHOD(purchase:(NSDictionary *)payload
                      resolver:(RCTPromiseResolveBlock)resolver
                          rejecter:(RCTPromiseRejectBlock)rejecter);

RCT_EXTERN_METHOD(restore:(RCTPromiseResolveBlock)resolver
                      rejecter:(RCTPromiseRejectBlock)rejecter);

RCT_EXTERN_METHOD(finishPurchasedTransaction:(NSDictionary *)payload
                      resolver:(RCTPromiseResolveBlock)resolver
                          rejecter:(RCTPromiseRejectBlock)rejecter);
@end
