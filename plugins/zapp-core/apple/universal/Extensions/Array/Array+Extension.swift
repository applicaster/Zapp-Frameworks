//
//  Array+Extension.swift
//  ZappCore
//
//  Created by Alex Zchut on 05/05/2021.
//

import Foundation

extension Sequence where Iterator.Element: Hashable {
    public func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}
