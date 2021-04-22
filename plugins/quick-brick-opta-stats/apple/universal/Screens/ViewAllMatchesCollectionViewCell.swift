//
//  ViewAllMatchesCollectionViewCell.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Marcos Reyes - Applicaster on 4/15/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import Foundation
import UIKit

class ViewAllMatchesCollectionViewCell: UICollectionViewCell {
    @IBOutlet var allMatchesImageView: UIImageView!

    override func awakeFromNib() {
        setImage()
    }

    override func prepareForReuse() {
        setImage()
    }

    private func setImage() {
        var imageToLoad = "all-matches-es"

        let deviceLocale = NSLocale.current.languageCode

        switch deviceLocale {
        case "en":
            imageToLoad = "all-matches-en"
        case "es":
            imageToLoad = "all-matches-es"
        case "pt":
            imageToLoad = "all-matches-pt"
        default:
            break
        }

        if let path = Bundle.main.path(forResource: imageToLoad, ofType: "jpg") {
            allMatchesImageView.image = UIImage(contentsOfFile: path)
        }
        allMatchesImageView.layer.cornerRadius = 9
        allMatchesImageView.clipsToBounds = true
    }
}
