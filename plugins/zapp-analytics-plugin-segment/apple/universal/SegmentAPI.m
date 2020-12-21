//
//  SegmentAPI.m
//  SegmentAnalyticsPlugin
//
//  Created by Avi Levin on 06/08/2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

#import "SegmentAPI.h"
#import <Analytics/SEGAnalytics.h>

@implementation SegmentAPI

// To export a module named SegmentAPI
RCT_EXPORT_MODULE()

/*
 identify lets you tie a user to their actions and record traits about them.
 It includes a unique User ID and any optional traits you know about them.

 We recommend calling identify a single time when the user’s account is first created,
 and only identifying again later when their traits are changed.

 Note: We automatically assign an anonymousId to users before you identify them.
 The userId is what connects anonymous activities across devices (e.g. iPhone and iPad).
 */
RCT_EXPORT_METHOD(identifyUser:(NSString *)identify
                  traits:(NSDictionary *)traits
                  options: (NSDictionary *)options)
{
    [[SEGAnalytics sharedAnalytics] identify:identify
                                      traits:traits
                                     options:options];
}
@end

