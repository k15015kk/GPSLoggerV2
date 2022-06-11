//
//  ActivityTypeTableViewController.swift
//  GPSLoggerV2
//
//  Created by 井上晴稀 on 2022/05/16.
//

import UIKit

class ActivityTypeTableViewController: UITableViewController {
    
    // MARK: Properties
    
    private var selectedRow: Int = 0
    
    private var activityType: Int {
        UserDefaults.standard.integer(forKey: "activityType")
    }

    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.selectedRow = activityType
        
        if let selectedCell = tableView.cellForRow(at: IndexPath(row: activityType, section: 0)) {
            selectedCell.accessoryType = .checkmark
        }
    }
}

// MARK: - UITableViewController

extension ActivityTypeTableViewController{
    
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
            return 5
        default :
            return 0
        }
    }
    
    /// セルを選択したときの処理です
    /// - Parameters:
    ///   - tableView: TableViewのオブジェクト
    ///   - indexPath: 選択したセルの情報
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        // すでに選択している場合は，何も発生しない
        if indexPath.row == selectedRow {
            return
        }
        
        // 選択中のセルを解除
        if let prevSelectedCell = tableView.cellForRow(at: IndexPath(row: selectedRow, section: 0)) {
            prevSelectedCell.accessoryType = .none
        }
        
        if let selectedCell = tableView.cellForRow(at: indexPath) {
            selectedCell.accessoryType = .checkmark
        }
        
        saveActivityType(activity: indexPath.row)
        selectedRow = self.activityType
    }
}

// MARK: - Others

extension ActivityTypeTableViewController {
    
    /// 選択したアクティビティタイプをUserDefaultsに保存します
    /// - Parameter activityType: 選択したアクティビティタイプ
    func saveActivityType(activity activityType: Int) {
        
        UserDefaults.standard.set(activityType, forKey: "activityType")
    }
}
