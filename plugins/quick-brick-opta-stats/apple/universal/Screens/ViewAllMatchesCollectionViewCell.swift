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
        var imageToLoad = "all-matches-es"

        if let deviceLocale = FacadeConnector.connector?.storage?.sessionStorageValue(for: "languageCode", namespace: nil) {
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
        }

        if let path = Bundle(for: classForCoder).path(forResource: imageToLoad, ofType: "jpg") {
            allMatchesImageView.image = UIImage(contentsOfFile: path)
        }
        allMatchesImageView.layer.cornerRadius = 9
        allMatchesImageView.clipsToBounds = true
    }
}
