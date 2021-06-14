//
//  OptaTeamContainerManagerBridgeExport.m
//  OptaStats
//
//  Created by Alex Zchut on 11/06/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

@import React;
#import <React/RCTViewManager.h>

@interface RCT_EXTERN_MODULE(OptaTeamContainerManager, RCTViewManager)

RCT_EXPORT_VIEW_PROPERTY(team, NSString);

@end
