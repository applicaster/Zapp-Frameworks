//
//  SwitchCell.swift
//  QuickBrickXray
//
//  Created by Anton Kononenko on 9/6/20.
//

import Foundation

class SwitchCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switcher: UISwitch!
    weak var delegate: SwitchCellDelegate?
    var indexPath: IndexPath?

    override func prepareForReuse() {
        super.prepareForReuse()

        titleLabel.text = nil
        switcher.isOn = false
        indexPath = nil
        delegate = nil
    }

    func update(title: String,
                enabled: Bool,
                indexPath: IndexPath,
                delegate: SwitchCellDelegate) {
        titleLabel.text = title
        switcher.isOn = enabled
        self.indexPath = indexPath
        self.delegate = delegate
    }

    @IBAction func switchChange(sender: UISwitch) {
        guard let indexPath = indexPath else {
            return
        }
        delegate?.switcherDidChange(value: sender.isOn,
                                    indexPath: indexPath)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
//            guard let self = self else { return }
//            self.delegate?.switcherDidChange(value: sender.isOn,
//                                             indexPath: indexPath)
//        }
    }
}
