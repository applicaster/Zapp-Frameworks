//
//  TimeoutTimer.swift
//  ZappApple
//
//  Created by Alex Zchut on 20/01/2021.
//

/// TimeoutTimer wrapps a callback deferral that may be cancelled.
///
/// Usage:
/// TimeoutTimer(1.0) { print("1 second has passed.") }
///

import Foundation

class TimeoutTimer: NSObject
{
    private var timer: Timer?
    private var callback: (() -> ())?

    init(_ delaySeconds: Double = 10, _ callback: (() -> ())?)
    {
        super.init()
        self.callback = callback
        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(delaySeconds),
                                          target: self,
                                          selector: #selector(invoke),
                                          userInfo: nil,
                                          repeats: false)
    }

    @objc func invoke()
    {
        self.callback?()
        // Discard callback and timer.
        self.callback = nil
        self.timer = nil
    }

    func cancel()
    {
        self.timer?.invalidate()
        self.timer = nil
    }
}
