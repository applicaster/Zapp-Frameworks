//
//  EmptySpacerTableViewCell.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Marcos Reyes - Applicaster on 3/10/19.
//

import Foundation

class EmptySpacerTableViewCell: UITableViewCell {
    var isTop: Bool = false {
        didSet {
            update()
        }
    }

    var customText: String?

    lazy var customLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.useRegularFont()
        return label
    }()

    override func awakeFromNib() {
        update()
        contentView.backgroundColor = UIColor.white
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        update()
        contentView.backgroundColor = UIColor.white
    }

    fileprivate func update() {
        if isTop {
            roundCorners(corners: [.topLeft, .topRight], radius: 15.0)
        } else {
            roundCorners(corners: [.bottomLeft, .bottomRight], radius: 15.0)
        }

        if let text = customText {
            customLabel.text = text

            if customLabel.superview == nil {
                customLabel.translatesAutoresizingMaskIntoConstraints = false
                addSubview(customLabel)
                addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[label]-20-|", options: [], metrics: nil, views: ["label": customLabel]))
                addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[label]", options: [], metrics: nil, views: ["label": customLabel]))
            }
        }
    }

    private func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
