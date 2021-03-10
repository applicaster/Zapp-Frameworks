//
//  SegmentAPI.m
//  SegmentAnalytics
//
//  Created by Avi Levin on 06/08/2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

@import React;

@interface RCT_EXTERN_MODULE(SegmentAPI, NSObject)

RCT_EXTERN_METHOD(identifyUser:(NSString *)identify
                  traits:(NSDictionary *)traits
                  options: (NSDictionary *)options)

@end


