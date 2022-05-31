//
//  String+localized.swift
//  GPSLoggerV2
//
//  Created by 井上晴稀 on 2022/06/01.
//

import Foundation

extension String {
    // 多言語対応
    var localized: String {
        return NSLocalizedString(self,
                                 tableName: nil,
                                 bundle: Bundle.main,
                                 value: "",
                                 comment: self
        )
    }
}
