//
//  Alert.swift
//  GPSLoggerV2
//
//  Created by 井上晴稀 on 2022/05/16.
//

import UIKit

class Alert {
    static func presentWarningAlert(_ title: String, _ message: String) -> UIAlertController {
        // アラートを定義
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // OKを押した際の処理を追加
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            alert.dismiss(animated: true)
        }
        
        // アラートにOKボタンを追加
        alert.addAction(ok)
        
        return alert
    }
}
