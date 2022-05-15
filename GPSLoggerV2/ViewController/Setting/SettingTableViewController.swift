//
//  SettingViewController.swift
//  GPSLoggerV2
//
//  Created by 井上晴稀 on 2022/05/15.
//

import UIKit

class SettingTableViewController: UITableViewController {
    
    @IBOutlet private weak var distanceFilterLabel: UILabel!
    @IBOutlet private weak var desiredAccuracyLabel: UILabel!
    @IBOutlet private weak var activityTypeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UserDefaultが保存されている場合，それを表示する
        if let distanceFilter = UserDefaults.standard.value(forKey: "distanceFilter") as? String {
            distanceFilterLabel.text = distanceFilter
        }
        
        if let desiredAccuracy = UserDefaults.standard.value(forKey: "desiredAccuracy") as? String {
            desiredAccuracyLabel.text = desiredAccuracy
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDefaultsDidChange),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }
    
    // MARK: TableViewのデータソース
    
    /// TableView内のセクション数を返します
    /// - Parameter tableView: TableViewのオブジェクト
    /// - Returns: セクション数
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /// セクションごとのRow数を返します
    /// - Parameters:
    ///   - tableView: TableViewのオブジェクト
    ///   - section: セクション情報（数値）
    /// - Returns: セクションごとのRow数
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /// セクションごとのRowを返す
        switch section {
        case 0:
            return 3
        default :
            return 0
        }
    }
    
    @objc func userDefaultsDidChange(_ notification: Notification) {
        // UserDefaultsの変更があったので画面の情報を更新する
        if let distanceFilter = UserDefaults.standard.value(forKey: "distanceFilter") as? String {
            distanceFilterLabel.text = distanceFilter
        }
        
        if let desiredAccuracy = UserDefaults.standard.value(forKey: "desiredAccuracy") as? String {
            desiredAccuracyLabel.text = desiredAccuracy
        }
    }
}
