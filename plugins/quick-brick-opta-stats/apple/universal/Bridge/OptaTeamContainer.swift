//
//  OptaTeamContainer.swift
//  OptaStats
//
//  Created by Alex Zchut on 11/06/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import React
import ZappCore

@objc public class OptaTeamContainer: UIView {
    fileprivate let pluginIdentifier = "quick-brick-opta-stats"
    
    @objc public var team: NSString? {
            didSet {
                addOptaTeamScreen()
            }
        }
    public init(eventDispatcher: RCTEventDispatcher) {
        super.init(frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func addOptaTeamScreen() {
        guard let teamId = team as String? else {
            return
        }
        pluginInstance?.showTeamScreen(on: self, teamId: teamId)
    }

    lazy var pluginInstance: OptaStats? = {
        return FacadeConnector.connector?.pluginManager?.getProviderInstance(identifier: pluginIdentifier) as? OptaStats
    }()
}
