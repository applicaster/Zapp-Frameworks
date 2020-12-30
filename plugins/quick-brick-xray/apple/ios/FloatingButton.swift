//
//  FloatingButton.swift
//  QuickBrickXray
//
//  Created by Alex Zchut on 30/12/2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

import UIKit

class FloatingButton: UIButton {
    var buttonLocation: CGPoint = CGPoint(x: 0, y: 0)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        let gesture = UIPanGestureRecognizer(target: self, action: #selector(buttonDrag(pan:)))
        addGestureRecognizer(gesture)
    }

    @objc func buttonDrag(pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            buttonLocation = pan.location(in: self)
        case .ended:
            superview?.constraint(withIdentifier: "\(tag)_left")?.constant = frame.origin.x
            superview?.constraint(withIdentifier: "\(tag)_top")?.constant = frame.origin.y
        default:
            let location = pan.location(in: superview) // get pan location
            frame.origin = CGPoint(x: location.x - buttonLocation.x, y: location.y - buttonLocation.y)
        }
    }
}

extension UIView {
    func constraint(withIdentifier identifier: String) -> NSLayoutConstraint? {
        return constraints.first { $0.identifier == identifier }
    }
}
