//
//  PlayerShirtView.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Jesus De Meyer on 4/24/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import UIKit

class PlayerShirtView: UIView {
    var text: String = "" {
        didSet {
            setNeedsDisplay()
        }
    }

    var isHomeTeam: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }

    fileprivate let label = UILabel(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    convenience init(text: String, radius: CGFloat) {
        self.init(frame: CGRect(x: 0, y: 0, width: radius, height: radius))

        self.text = text
    }

    fileprivate func commonInit() {
        label.textAlignment = .center
        label.useRegularFont()
    }

    override func draw(_ rect: CGRect) {
        let theBounds = CGRect(x: 0, y: 0, width: rect.width, height: rect.height)

        // UIColor.white.setFill()
        // UIRectFill(theBounds)

        if let layers = layer.sublayers {
            for sl in layers {
                sl.removeFromSuperlayer()
            }
        }
        label.removeFromSuperview()

        let shapeLayerFrame = theBounds.insetBy(dx: 1.0, dy: 1.0)
        let shapeLayer = CAShapeLayer()

        shapeLayer.path = UIBezierPath(ovalIn: shapeLayerFrame).cgPath
        shapeLayer.frame = theBounds

        if isHomeTeam {
            label.textColor = UIColor.white
            shapeLayer.fillColor = UIColor(white: 0.9, alpha: 1.0).cgColor
            shapeLayer.lineWidth = 0
        } else {
            label.textColor = UIColor(red: 151.0 / 255.0, green: 151.0 / 255.0, blue: 151.0 / 255.0, alpha: 1.0)
            shapeLayer.lineWidth = 1.0
            shapeLayer.fillColor = UIColor.white.cgColor
            shapeLayer.strokeColor = UIColor(red: 151.0 / 255.0, green: 151.0 / 255.0, blue: 151.0 / 255.0, alpha: 1.0).cgColor
        }

        layer.addSublayer(shapeLayer)

        label.frame = theBounds
        label.text = text
        label.font = UIFont.systemFont(ofSize: theBounds.height * 0.5)

        addSubview(label)
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setNeedsDisplay()
    }

    override func updateConstraints() {
        super.updateConstraints()
        setNeedsDisplay()
    }
}
