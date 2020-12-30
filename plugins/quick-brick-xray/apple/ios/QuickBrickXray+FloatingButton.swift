//
//  QuickBrickXray+FloatingButton.swift
//  QuickBrickXray
//
//  Created by Alex Zchut on 30/12/2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

import Foundation

extension QuickBrickXray {
    func prepareXRayFloatingButton() {
        guard currentSettings?.showXrayFloatingButtonEnabled == true else {
            currentXRayFloatingButton()?.removeFromSuperview()
            return
        }
        
        guard let targetView = UIApplication.shared.keyWindow else {
            delayPresentationOfEnabledXRayButton()
            return
        }
        // remove current button if exists
        currentXRayFloatingButton()?.removeFromSuperview()

        let button = FloatingButton(frame: CGRect.zero)
        button.tag = xRayFloatingButtonTag()
        button.setTitle("XRay", for: .normal)
        button.backgroundColor = UIColor.darkGray
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.cornerRadius = 15.0
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false

        if targetView.subviews.count > 1,
           let lastView = targetView.subviews.last {
            targetView.insertSubview(button, belowSubview: lastView)
        }
        else {
            targetView.addSubview(button)
        }
        
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        button.leftAnchor.constraintEqualTo(anchor: targetView.leftAnchor, constant: 40, identifier: "\(button.tag)_left").isActive = true
        button.topAnchor.constraintEqualTo(anchor: targetView.topAnchor, constant: 100, identifier: "\(button.tag)_top").isActive = true

        if #available(iOS 14.0, *) {
            button.addAction(UIAction(handler: xRayButtonPressed), for: .touchUpInside)
        } else {
            // Fallback on earlier versions
            button.addTarget(self, action: #selector(xRayButtonPressed(_:)), for: .touchUpInside)
        }
    }

    @objc func xRayButtonPressed(_ sender: Any) {
        guard let scheme = appUrlScheme(),
              let url = URL(string: "\(scheme)://xray") else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    fileprivate func delayPresentationOfEnabledXRayButton() {
        guard let scheme = appUrlScheme(),
              let url = URL(string: "\(scheme)://xray?showXrayFloatingButtonEnabled=true") else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    fileprivate func xRayFloatingButtonTag() -> Int {
        return 985529
    }

    fileprivate func currentXRayFloatingButton() -> UIView? {
        return UIApplication.shared.keyWindow?.viewWithTag(xRayFloatingButtonTag())
    }
    
    fileprivate func appUrlScheme() -> String? {
        if let arrUrlTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: AnyObject]],
           let arrUrlSchemes = arrUrlTypes.first?["CFBundleURLSchemes"] as? [AnyObject],
           let firstObject = arrUrlSchemes.first as? String {
            return firstObject
        } else {
            return nil
        }
    }
}


extension NSLayoutAnchor {
    @objc func constraintEqualTo(anchor: NSLayoutAnchor!, constant:CGFloat, identifier:String) -> NSLayoutConstraint! {
        let constraint = self.constraint(equalTo: anchor, constant:constant)
        constraint.identifier = identifier
        return constraint
    }
}
