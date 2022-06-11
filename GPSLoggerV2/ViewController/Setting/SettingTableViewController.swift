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
    
    // MARK: Properties
    
    // 距離フィルタ
    private var distanceFilter: Float {
        UserDefaults.standard.float(forKey: "distanceFilter")
    }
    
    // 精度フィルタ
    private var desiredAccuracy: Float {
        UserDefaults.standard.float(forKey: "desiredAccuracy")
    }
    
    // アクティビティタイプ
    private var activityType: Int {
        UserDefaults.standard.integer(forKey: "activityType")
    }
    
    // アクティビティタイプのテキスト
    private var activityTypeText: String {
        switch activityType {
        case 0:
            return "activity_fitness".localized
        case 1:
            return "activity_automotive".localized
        case 2:
            return "activity_othermotive".localized
        case 3:
            return "activity_airborne".localized
        case 4:
            return "acitivty_other".localized
        default:
            return "acitivty_other".localized
        }
    }
    
    // バックグラウンド制御
    private var backgroundFetch: Bool {
        UserDefaults.standard.bool(forKey: "backgroundLocationFetch")
    }
    
    // 位置情報の自動一時停止
    private var automaticallyLocationUpdatePauses: Bool {
        UserDefaults.standard.bool(forKey: "automaticallyLocationUpdatePauses")
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// UserDefaultが保存されている場合，それを表示する
        
        // UIのラベルテキストを設定
        distanceFilterLabel.text = String(distanceFilter)
        desiredAccuracyLabel.text = String(desiredAccuracy)
        activityTypeLabel.text = activityTypeText
        
        // バックグラウンド制御
        backgroundFetchSwitch.setOn(backgroundFetch, animated: false)
        
        // 位置情報の自動一時停止
        automaticallyUpdatePausesSwitch.setOn(automaticallyLocationUpdatePauses, animated: false)
        
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
        distanceFilterLabel.text = String(self.distanceFilter)
        
        // 精度の更新
        desiredAccuracyLabel.text = String(self.desiredAccuracy)
        
        // アクティビティタイプの更新
        activityTypeLabel.text = self.activityTypeText
    }
}
