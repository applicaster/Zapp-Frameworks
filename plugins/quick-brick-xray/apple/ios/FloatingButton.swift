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
        self.addGestureRecognizer(gesture)

    }

    @objc func buttonDrag(pan: UIPanGestureRecognizer) {
        if pan.state == .began {
            buttonLocation = pan.location(in: self)
        } else {
            let location = pan.location(in: self.superview) // get pan location
            self.frame.origin = CGPoint(x: location.x - buttonLocation.x, y: location.y - buttonLocation.y)
        }
    }
}
