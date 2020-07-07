//
//  UIView+Additions.swift
//  ZappApple
//
//  Created by Anton Kononenko on 10/15/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

import UIKit
extension UIView {
    func matchParent() {
        guard superview != nil else {
            return
        }
        setInsetsFromParent(insets: .zero)
    }

    func setInsetsFromParent(insets: UIEdgeInsets) {
        guard let superView = self.superview else {
            return
        }
        if translatesAutoresizingMaskIntoConstraints {
            autoresizingMask = [.flexibleWidth, .flexibleHeight]

            var newFrame: CGRect = superView.bounds
            let fixedWidth = superView.bounds.size.width - insets.left - insets.right
            let fixedHeight = superView.bounds.size.height - insets.top - insets.bottom

            if fixedWidth > 0 && fixedHeight > 0 {
                newFrame = CGRect(x: insets.left,
                                  y: insets.top,
                                  width: fixedWidth,
                                  height: fixedHeight)
            }

            frame = newFrame
        } else {
            clearAllConstraintOfAlignment()
            superview?.addConstraint(NSLayoutConstraint(item: self,
                                                        attribute: .top,
                                                        relatedBy: .equal,
                                                        toItem: superview,
                                                        attribute: .top,
                                                        multiplier: 1.0,
                                                        constant: insets.top))

            superview?.addConstraint(NSLayoutConstraint(item: self,
                                                        attribute: .leading,
                                                        relatedBy: .equal,
                                                        toItem: superview,
                                                        attribute: .leading,
                                                        multiplier: 1.0,
                                                        constant: insets.left))

            superview?.addConstraint(NSLayoutConstraint(item: self,
                                                        attribute: .bottom,
                                                        relatedBy: .equal,
                                                        toItem: superview,
                                                        attribute: .bottom,
                                                        multiplier: 1.0,
                                                        constant: insets.bottom))

            superview?.addConstraint(NSLayoutConstraint(item: self,
                                                        attribute: .trailing,
                                                        relatedBy: .equal,
                                                        toItem: superview,
                                                        attribute: .trailing,
                                                        multiplier: 1.0,
                                                        constant: insets.right))
        }
    }

    func clearAllConstraintOfAlignment() {
        var constraints = [NSLayoutConstraint]()
        if let superView = self.superview {
            for constraint in superView.constraints {
                if (constraint.firstItem as? UIView) == self ||
                    (constraint.secondItem as? UIView) == self {
                    constraints.append(constraint)
                }
            }
            NSLayoutConstraint.deactivate(constraints)
        }

        var widthAndHeightConstraints = [NSLayoutConstraint]()
        for constraint in self.constraints {
            if (constraint.firstItem as? UIView) == self {
                widthAndHeightConstraints.append(constraint)
            }
        }
        NSLayoutConstraint.deactivate(widthAndHeightConstraints)
    }
}
