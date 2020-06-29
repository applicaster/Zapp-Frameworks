//
//  ChromecastAdapterBridgeExport.m
//  ZappGeneralPluginChromecast
//
//  Created by Alex Zchut on 29/03/2020.
//  Copyright © 2020 Applicaster. All rights reserved.
//

@import React;
#import <React/RCTViewManager.h>

@interface RCT_EXTERN_MODULE(ChromecastButtonManager, RCTViewManager)

RCT_EXPORT_VIEW_PROPERTY(origin, NSString);
RCT_EXPORT_VIEW_PROPERTY(tintColor, UIColor);

@end
