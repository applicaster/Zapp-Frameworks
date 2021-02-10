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

class TimeoutTimer: NSObject {
    private var timer: Timer?
    private var callback: (() -> Void)?

    init(_ delaySeconds: Double = 10, _ callback: (() -> Void)?) {
        super.init()
        self.callback = callback
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(delaySeconds),
                                     target: self,
                                     selector: #selector(invoke),
                                     userInfo: nil,
                                     repeats: false)
    }

    @objc func invoke() {
        callback?()
        // Discard callback and timer.
        callback = nil
        timer = nil
    }

    func cancel() {
        timer?.invalidate()
        timer = nil
    }
}
