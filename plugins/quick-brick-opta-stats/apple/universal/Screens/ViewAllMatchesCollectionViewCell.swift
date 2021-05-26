//
//  ViewAllMatchesCollectionViewCell.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Marcos Reyes - Applicaster on 4/15/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import Foundation
import UIKit
import ZappCore

class ViewAllMatchesCollectionViewCell: UICollectionViewCell {
    @IBOutlet var allMatchesImageView: UIImageView!

    override func awakeFromNib() {
        setImage()
    }

    override func prepareForReuse() {
        setImage()
    }

    private func setImage() {
        let imageToLoad = "\(OptaStats.pluginParams.imageBaseUrl)all-matches-\(Helpers.currentYear)-\(Localized.languageCode).png"
        allMatchesImageView.sd_setImage(with: URL(string: imageToLoad), placeholderImage: nil)
        
        allMatchesImageView.layer.cornerRadius = 9
        allMatchesImageView.clipsToBounds = true
    }
}
