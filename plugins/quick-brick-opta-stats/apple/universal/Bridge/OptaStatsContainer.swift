//
//  OptaStatsContainer.swift
//  OptaStats
//
//  Created by Alex Zchut on 11/04/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import React
import ZappCore

@objc public class OptaStatsContainer: UIView {
    fileprivate let pluginIdentifier = "quick-brick-opta-stats"

    public init(eventDispatcher: RCTEventDispatcher) {
        super.init(frame: .zero)
        addOptaStatsScreen()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func addOptaStatsScreen() {
        pluginInstance?.showScreen(on: self)
    }

    lazy var pluginInstance: OptaStats? = {
        return FacadeConnector.connector?.pluginManager?.getProviderInstance(identifier: pluginIdentifier) as? OptaStats
    }()
}
