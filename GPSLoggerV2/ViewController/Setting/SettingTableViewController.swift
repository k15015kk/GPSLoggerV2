//
//  SettingViewController.swift
//  GPSLoggerV2
//
//  Created by 井上晴稀 on 2022/05/15.
//

import UIKit

class SettingTableViewController: UITableViewController {
    
    // MARK: UI
    
    @IBOutlet private weak var distanceFilterLabel: UILabel!
    @IBOutlet private weak var desiredAccuracyLabel: UILabel!
    @IBOutlet private weak var activityTypeLabel: UILabel!
    @IBOutlet private weak var backgroundFetchSwitch: UISwitch!
    @IBOutlet private weak var automaticallyUpdatePausesSwitch: UISwitch!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// UserDefaultが保存されている場合，それを表示する
        
        // 距離フィルタ
        let distanceFilter = UserDefaults.standard.float(forKey: "distanceFilter")
        distanceFilterLabel.text = String(distanceFilter)
        
        // 精度フィルタ
        let desiredAccuracy = UserDefaults.standard.float(forKey: "desiredAccuracy")
        desiredAccuracyLabel.text = String(desiredAccuracy)
        
        // アクティビティタイプ
        let activityType = UserDefaults.standard.integer(forKey: "activityType")
        
        switch activityType {
        case 0:
            activityTypeLabel.text = "フィットネス"
        case 1:
            activityTypeLabel.text = "オートモーティブナビゲーション"
        case 2:
            activityTypeLabel.text = "その他の車両ナビゲーション"
        case 3:
            activityTypeLabel.text = "空中"
        case 4:
            activityTypeLabel.text = "その他"
        default:
            activityTypeLabel.text = "その他"
        }
        
        // バックグラウンド制御
        let backgroundFetch = UserDefaults.standard.bool(forKey: "backgroundLocationFetch")
        backgroundFetchSwitch.setOn(backgroundFetch, animated: false)
        
        // 位置情報の自動一時停止
        let automaticallyPausesUpdate = UserDefaults.standard.bool(forKey: "automaticallyLocationUpdatePauses")
        automaticallyUpdatePausesSwitch.setOn(automaticallyPausesUpdate, animated: false)
        
        // UserDefaultsの更新通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDefaultsDidChange),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }
    
    // MARK: Actions
    
    /// バックグランド取得のスイッチを選択したときの処理
    /// - Parameter sender: UISwitchのSender情報
    @IBAction private func actionSwitchBackgroundFetch(_ sender: UISwitch) {
        
        // バックグランド取得をUserDefaultsに設定
        if sender.isOn {
            
            UserDefaults.standard.set(true, forKey: "backgroundLocationFetch")
        } else {
            
            UserDefaults.standard.set(false, forKey: "backgroundLocationFetch")
        }
    }

    /// バッテリー制御のスイッチを選択したときの処理
    /// - Parameter sender: UISwitchのSender情報
    @IBAction func actionSwitchLocationUpdatePauses(_ sender: UISwitch) {
        
        // バッテリー制御をUserDefaultsに設定
        if sender.isOn {
            
            UserDefaults.standard.set(true, forKey: "automaticallyLocationUpdatePauses")
        } else {
            
            UserDefaults.standard.set(false, forKey: "automaticallyLocationUpdatePauses")

        }
    }
}

// MARK: - UITableViewController

extension SettingTableViewController {
    
    /// TableView内のセクション数を返します
    /// - Parameter tableView: TableViewのオブジェクト
    /// - Returns: セクション数
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    /// セクションごとのRow数を返します
    /// - Parameters:
    ///   - tableView: TableViewのオブジェクト
    ///   - section: セクション情報（数値）
    /// - Returns: セクションごとのRow数
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /// セクションごとのRowを返す
        /// case0 : 取得間隔・精度
        /// case1 : 位置取得制御
        switch section {
        case 0:
            return 3
        case 1:
            return 2
        default :
            return 0
        }
    }
}

// MARK: - NotificationObserver

extension SettingTableViewController {
    
    /// UserDefaultsが更新されたときに実行
    /// - Parameter notification: Notification情報
    @objc func userDefaultsDidChange(_ notification: Notification) {
        
        // 距離の更新
        let distanceFilter = UserDefaults.standard.float(forKey: "distanceFilter")
        distanceFilterLabel.text = String(distanceFilter)
        
        // 精度の更新
        let desiredAccuracy = UserDefaults.standard.float(forKey: "desiredAccuracy")
        desiredAccuracyLabel.text = String(desiredAccuracy)
        
        // アクティビティタイプの更新
        let activityType = UserDefaults.standard.integer(forKey: "activityType")
        
        switch activityType {
        case 0:
            activityTypeLabel.text = "フィットネス"
        case 1:
            activityTypeLabel.text = "オートモーティブナビゲーション"
        case 2:
            activityTypeLabel.text = "その他の車両ナビゲーション"
        case 3:
            activityTypeLabel.text = "空中"
        case 4:
            activityTypeLabel.text = "その他"
        default:
            activityTypeLabel.text = "未設定"
        }
    }
}
