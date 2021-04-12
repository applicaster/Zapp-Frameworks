//
//  CopaAmericaStatsBridgeExport.m
//  CopaAmericaStats
//
//  Created by Alex Zchut on 11/04/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

@import React;

@interface RCT_EXTERN_MODULE (CopaAmericaStatsBridge, NSObject)

RCT_EXTERN_METHOD(fetchMatchScreenDetails:(NSString *)fixtureId resolver:(RCTPromiseResolveBlock)resolve rejecter: (RCTPromiseRejectBlock) reject);
RCT_EXTERN_METHOD(fetchMatchDetails:(NSString *)matchId resolver:(RCTPromiseResolveBlock)resolve rejecter: (RCTPromiseRejectBlock) reject);
RCT_EXTERN_METHOD(fetchLineUp:(NSString *)contestantId resolver:(RCTPromiseResolveBlock)resolve rejecter: (RCTPromiseRejectBlock) reject);
RCT_EXTERN_METHOD(fetchGroupCards:(NSString *)tournamentCalendar resolver:(RCTPromiseResolveBlock)resolve rejecter: (RCTPromiseRejectBlock) reject);
RCT_EXTERN_METHOD(fetchAllMatches:(NSString *)tournamentCalendar resolver:(RCTPromiseResolveBlock)resolve rejecter: (RCTPromiseRejectBlock) reject);
RCT_EXTERN_METHOD(fetchAllMatchesGrouped:(NSString *)tournamentCalendar resolver:(RCTPromiseResolveBlock)resolve rejecter: (RCTPromiseRejectBlock) reject);
RCT_EXTERN_METHOD(fetchTournamentWinners:(NSString *)competitionId resolver:(RCTPromiseResolveBlock)resolve rejecter: (RCTPromiseRejectBlock) reject);
RCT_EXTERN_METHOD(fetchPlayerScreenCareer:(NSString *)tournamentCalendar contestantId:(NSString *)contestantId resolver:(RCTPromiseResolveBlock)resolve rejecter: (RCTPromiseRejectBlock) reject);
RCT_EXTERN_METHOD(fetchTeamScreenDetails:(NSString *)tournamentCalendar contestantId:(NSString *)contestantId resolver:(RCTPromiseResolveBlock)resolve rejecter: (RCTPromiseRejectBlock) reject);
RCT_EXTERN_METHOD(fetchPlayerScreenFullSquad:(NSString *)tournamentCalendar contestantId:(NSString *)contestantId resolver:(RCTPromiseResolveBlock)resolve rejecter: (RCTPromiseRejectBlock) reject);

@end
