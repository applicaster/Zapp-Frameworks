//
//  CopaAmericaStatsBridge.swift
//  CopaAmericaStats
//
//  Created by Alex Zchut on 11/04/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import React
import ZappCore

@objc(CopaAmericaStatsBridge)
class CopaAmericaStatsBridge: NSObject, RCTBridgeModule {
    fileprivate let pluginIdentifier = "quick-brick-copa-america-stats"
    var bridge: RCTBridge!

    static func moduleName() -> String! {
        return "CopaAmericaStatsBridge"
    }

    public class func requiresMainQueueSetup() -> Bool {
        return true
    }

    /// prefered thread on which to run this native module
    @objc public var methodQueue: DispatchQueue {
        return DispatchQueue.main
    }

    var pluginInstance: CopaAmericaStats? {
        guard let provider = FacadeConnector.connector?.pluginManager?.getProviderInstance(identifier: pluginIdentifier) as? CopaAmericaStats else {
            return nil
        }
        return provider
    }

    @objc public func fetchMatchScreenDetails(_ fixtureId: String,
                                              resolver: @escaping RCTPromiseResolveBlock,
                                              rejecter: @escaping RCTPromiseRejectBlock) {
        guard let pluginInstance = self.pluginInstance else {
            rejecter("failure", "plugin not available", nil)
            return
        }

        pluginInstance.fetchMatchScreenDetails(fixtureId: fixtureId,
                                               completion: { success, json in
                                                   if success {
                                                       resolver(json)
                                                   } else {
                                                       rejecter("failure", "fetchMatchScreenDetails failed", nil)
                                                   }
                                               })
    }

    @objc public func fetchMatchDetails(_ matchId: String,
                                        resolver: @escaping RCTPromiseResolveBlock,
                                        rejecter: @escaping RCTPromiseRejectBlock) {
        guard let pluginInstance = self.pluginInstance else {
            rejecter("failure", "plugin not available", nil)
            return
        }

        pluginInstance.fetchMatchDetails(matchId: matchId,
                                         completion: { success, json in
                                             if success {
                                                 resolver(json)
                                             } else {
                                                 rejecter("failure", "fetchMatchDetails failed", nil)
                                             }
                                         })
    }

    @objc public func fetchLineUp(_ contestantId: String,
                                  resolver: @escaping RCTPromiseResolveBlock,
                                  rejecter: @escaping RCTPromiseRejectBlock) {
        guard let pluginInstance = self.pluginInstance else {
            rejecter("failure", "plugin not available", nil)
            return
        }

        pluginInstance.fetchLineUp(contestantId: contestantId,
                                   completion: { success, json in
                                       if success {
                                           resolver(json)
                                       } else {
                                           rejecter("failure", "fetchLineUp failed", nil)
                                       }
                                   })
    }

    @objc public func fetchGroupCards(_ tournamentCalendar: String,
                                      resolver: @escaping RCTPromiseResolveBlock,
                                      rejecter: @escaping RCTPromiseRejectBlock) {
        guard let pluginInstance = self.pluginInstance else {
            rejecter("failure", "plugin not available", nil)
            return
        }

        pluginInstance.fetchGroupCards(tournamentCalendar: tournamentCalendar,
                                       completion: { success, json in
                                           if success {
                                               resolver(json)
                                           } else {
                                               rejecter("failure", "fetchGroupCards failed", nil)
                                           }
                                       })
    }

    @objc public func fetchAllMatches(_ tournamentCalendar: String,
                                      resolver: @escaping RCTPromiseResolveBlock,
                                      rejecter: @escaping RCTPromiseRejectBlock) {
        guard let pluginInstance = self.pluginInstance else {
            rejecter("failure", "plugin not available", nil)
            return
        }

        pluginInstance.fetchAllMatches(tournamentCalendar: tournamentCalendar,
                                       completion: { success, json in
                                           if success {
                                               resolver(json)
                                           } else {
                                               rejecter("failure", "fetchAllMatches failed", nil)
                                           }
                                       })
    }

    @objc public func fetchAllMatchesGrouped(_ tournamentCalendar: String,
                                             resolver: @escaping RCTPromiseResolveBlock,
                                             rejecter: @escaping RCTPromiseRejectBlock) {
        guard let pluginInstance = self.pluginInstance else {
            rejecter("failure", "plugin not available", nil)
            return
        }

        pluginInstance.fetchAllMatchesGrouped(tournamentCalendar: tournamentCalendar,
                                              completion: { success, json in
                                                  if success {
                                                      resolver(json)
                                                  } else {
                                                      rejecter("failure", "fetchAllMatchesGrouped failed", nil)
                                                  }
                                              })
    }

    @objc public func fetchTournamentWinners(_ competitionId: String,
                                             resolver: @escaping RCTPromiseResolveBlock,
                                             rejecter: @escaping RCTPromiseRejectBlock) {
        guard let pluginInstance = self.pluginInstance else {
            rejecter("failure", "plugin not available", nil)
            return
        }

        pluginInstance.fetchTournamentWinners(competitionId: competitionId,
                                              completion: { success, json in
                                                  if success {
                                                      resolver(json)
                                                  } else {
                                                      rejecter("failure", "fetchTournamentWinners failed", nil)
                                                  }
                                              })
    }

    @objc public func fetchPlayerScreenCareer(_ personId: String,
                                              resolver: @escaping RCTPromiseResolveBlock,
                                              rejecter: @escaping RCTPromiseRejectBlock) {
        guard let pluginInstance = self.pluginInstance else {
            rejecter("failure", "plugin not available", nil)
            return
        }

        pluginInstance.fetchPlayerScreenCareer(personId: personId,
                                               completion: { success, json in
                                                   if success {
                                                       resolver(json)
                                                   } else {
                                                       rejecter("failure", "fetchPlayerScreenCareer failed", nil)
                                                   }
                                               })
    }

    @objc public func fetchTeamScreenDetails(_ tournamentCalendar: String,
                                             contestantId: String,
                                             resolver: @escaping RCTPromiseResolveBlock,
                                             rejecter: @escaping RCTPromiseRejectBlock) {
        guard let pluginInstance = self.pluginInstance else {
            rejecter("failure", "plugin not available", nil)
            return
        }

        pluginInstance.fetchTeamScreenDetails(tournamentCalendar: tournamentCalendar,
                                              contestantId: contestantId,
                                              completion: { success, json in
                                                  if success {
                                                      resolver(json)
                                                  } else {
                                                      rejecter("failure", "fetchTeamScreenDetails failed", nil)
                                                  }
                                              })
    }

    @objc public func fetchPlayerScreenFullSquad(_ tournamentCalendar: String,
                                                 contestantId: String,
                                                 resolver: @escaping RCTPromiseResolveBlock,
                                                 rejecter: @escaping RCTPromiseRejectBlock) {
        guard let pluginInstance = self.pluginInstance else {
            rejecter("failure", "plugin not available", nil)
            return
        }

        pluginInstance.fetchPlayerScreenFullSquad(tournamentCalendar: tournamentCalendar,
                                                  contestantId: contestantId,
                                                  completion: { success, json in
                                                      if success {
                                                          resolver(json)
                                                      } else {
                                                          rejecter("failure", "fetchPlayerScreenFullSquad failed", nil)
                                                      }
                                                  })
    }
}
