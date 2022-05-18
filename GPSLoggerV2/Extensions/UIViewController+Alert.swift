//
//  Alert.swift
//  GPSLoggerV2
//
//  Created by 井上晴稀 on 2022/05/16.
//

import UIKit

public extension UIViewController {
    func presentWarningAlert(_ title: String, _ message: String) {
        // アラートを定義
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // OKを押した際の処理を追加
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            alert.dismiss(animated: true)
        }
        
        // アラートにOKボタンを追加
        alert.addAction(ok)
        present(alert, animated: false)
    }
    
    func presentChoicesAlert(_ title: String, _ message: String, _ actions:[UIAlertAction]) {
        // アラートを定義
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach{ alert.addAction($0) }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alert.dismiss(animated: true)
        }
        
        alert.addAction(cancelAction)
        
        present(alert, animated: false)
    }
}
